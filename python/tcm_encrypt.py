#!/usr/bin/env python3

import argparse

parser = argparse.ArgumentParser(description='')
parser = argparse.ArgumentParser()
parser.add_argument('flash_image', nargs=1, type=argparse.FileType('rb'))
parser.add_argument('flash_offset', nargs=1, type=int)
parser.add_argument('itcm_image', nargs=1, type=argparse.FileType('rb'))
parser.add_argument('code', nargs=1, type=argparse.FileType('rb'))
parser.add_argument('flash_out', nargs=1, type=argparse.FileType('wb'))
args = parser.parse_args()


def xor(b1, b2): 
    result = bytearray()
    for b1, b2 in zip(b1, b2):
        result.append(b1 ^ b2)
    return result


flash_image = args.flash_image[0].read()
itcm_image = args.itcm_image[0].read()
code = args.code[0].read()

xor_image = xor(itcm_image[:len(code)], flash_image[args.flash_offset[0]:args.flash_offset[0]+len(code)])

new_flash_part = xor(code, xor_image)
flash_end = flash_image[args.flash_offset[0] + len(code):]

if (args.flash_offset[0] > 0):
    args.flash_out[0].write(flash_image[:args.flash_offset[0]])

args.flash_out[0].write(new_flash_part)
args.flash_out[0].write(flash_end)
