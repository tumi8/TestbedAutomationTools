#!/usr/bin/env python3
#  Labeling.py, used to create keyfiles for network dumps 
#  Copyright (C) 2016  Christian Luebben
#  Params: main dump, dump-folder, id-folder, keyfile
#  Remark: UID and GID available in tlv header

import sys
import os
import hashlib
from timeit import default_timer as timer
from scapy.all import RawPcapReader

######################## Extract payload from TLV Packet ######################
def findpayloadtlv(pointer, act, filename, namedict):#Parse the TLV-Header and return l3pkt, cgroupID
    length2 = int.from_bytes(act[(pointer):(pointer+2)], 'little')
    type2 = int.from_bytes(act[(pointer+2):(pointer+4)], 'little')
    retval = False

    if length2 < 8:
        length2 = 8

    if length2 == 18:
        length2 = 20

    if length2 == 0:
        print("error")

    if type2 == 9:

        group1 = int.from_bytes(act[2:4], 'big')#little endian #CgroupID
        origin = filename.partition(".")[0]
        foundval = False

        if origin in namedict:
            foundval = (act[(pointer+4):(pointer+length2)], group1) #instead of groupID whole IDstring could be stored but more memory consuming
        return foundval

    if type2 == 10:
        retval = findpayloadtlv(pointer+8, act, filename, namedict)

    if type2 != 9 and type2 != 10 and type2 < 18:
        retval = findpayloadtlv(pointer+length2, act, filename, namedict)

    return retval
###############################################################################

######################## Search for corresponding packet in TLV dumps #########
def searchpcap(pkt, filenames, pcapdict, framecounter, namedict, target):

    returnvalue = False
    shawert = hashlib.sha512(pkt[14:]).hexdigest()

    for filename in filenames:

        origin = filename.partition(".")[0]

        if shawert in pcapdict[filename]:

            returnvalue = True
            group1 = str(pcapdict[filename][shawert])

            if  group1 in namedict[origin]: #namedict[origin] is iddict containing Log details

                target.write(str(framecounter)+";"+group1+";"+filename+";"+namedict[origin][group1])

            else:
                target.write(str(framecounter)+";"+group1+";"+filename+"\n")

    return returnvalue
###############################################################################

######################## creating dict for ids ################################
def createiddict(idfolder):
    idfilenames = os.listdir(idfolder)
    idfilenames.sort()

    namedict = {}#benennung der dicts direkt nach filenames unschoen bei fehlern, falls id file und somit dict nicht vorhanden

    #dictionary erzeugen zu beginn des labeling
    for idfilename in idfilenames:

        iddict = {}
        idfile = open(idfolder+idfilename, "rb")
        lines = idfile.readlines()[1:]#lesen ab 1. zeile difference between readlines and readline
        for line in lines:
            info = (line.decode()).partition(";")
            iddict[info[0]] = info[2]

        namedict[idfilename.partition(".")[0]] = iddict

    return namedict
###############################################################################

######################## creating dict for pcaps ##############################
def loadpcaps(folder, namedict):
    filenames = os.listdir(folder) #read al filenames in folder
    pcapdict = {}

    for filename in filenames:
        packetdict = {}

        with RawPcapReader(folder+filename) as sub_pcap_reader:
            for sub_raw_pkt in sub_pcap_reader:
                sub_pkt = sub_raw_pkt[0]

                l3pkt = findpayloadtlv(4, sub_pkt, filename, namedict) #first 4B can be skipped
                l3pkthash = hashlib.sha512(l3pkt[0]).hexdigest()

                if l3pkt[1] == 0:#necessary because subdumps sometimes contain duplicate packets w. ID=0
                    if l3pkthash in packetdict:
                        continue
                packetdict[l3pkthash] = l3pkt[1]

        pcapdict[filename] = packetdict

    return (filenames, pcapdict)
######################## Main #################################################
def main():

    start = timer()
    try: #if len groesser, -h for help, pcap ng - Fehlerbehandlung bei Fehleingaben
        dump = sys.argv[1]
        folder = sys.argv[2]
        idfolder = sys.argv[3]
        outpath = "keyfile"#set default value
    except:
        print("keyfile creation failed, check params")
        sys.exit(0)

    try:
        outpath = sys.argv[4]
        target = open(outpath, 'w')
        print("writing key entries to: " +str(outpath))
    except:
        try:
            target = open("keyfile", 'w')
            print("writing key entries to: " +str(outpath))
        except:
            print("keyfile creation failed, check params")
            sys.exit(0)

    if os.path.exists(dump) is True and os.path.exists(folder) is True and os.path.exists(folder) is True:
        print("Input valid")
    else:
        print("Check file paths")
        sys.exit(0)

    namedict = createiddict(idfolder) #namedict[filename] = corresponding idfile as iddict[cgroupID] = values)

    framecounter = 0

    ldpcapstart = timer()

    loadedpcaps = loadpcaps(folder, namedict)#gives dict with key filename that gives dict with key l3pkt:cgroupID
    filenames = loadedpcaps[0]
    pcapdict = loadedpcaps[1]

    ldpcapend = timer()
    labstart = timer()

    with RawPcapReader(dump) as pcap_reader:
        for raw_pkt in pcap_reader:
            framecounter += 1
            pktnbr = framecounter
            pkt = raw_pkt[0]

            if pkt[12:14] is b'\x08\x00' or pkt[12:14] is b'\x86\xdd':

                gefunden = False
                gefunden = searchpcap(pkt, filenames, pcapdict, framecounter, namedict, target)

                if gefunden is False:#if packet not found write the following to keyfile
                    target.write(str(framecounter)+";"+"-1"+";"+"\n")
            else:
                target.write(str(framecounter)+";"+"-1"+";"+"noL3"+";"+"noL3"+";"+"\n")
                continue

        #except:
            #print ("malformed packet")

    labend = timer()
    target.close()
    end = timer()

    print("Time to load Pcaps to dict: " + str(ldpcapend - ldpcapstart))
    print("Time to label: " + str(labend - labstart))

    duration = float(end - start)
    print("Time per packet: " + str(duration/pktnbr))
    print("Packets per second: " + str(1/(duration/pktnbr)))
    print("Total packets: " + str(pktnbr))
    print("Execution time: " + str(duration))

if __name__ == "__main__":
    sys.exit(main())
######################## EOF ##################################################
