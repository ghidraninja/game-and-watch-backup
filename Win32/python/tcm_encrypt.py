#!/usr/bin/env python3

import argparse
import sys

parser = argparse.ArgumentParser(description='')
parser = argparse.ArgumentParser()
parser.add_argument('flash_image', nargs=1, type=argparse.FileType('rb'))
parser.add_argument('tcm_ram_image', nargs=1, type=argparse.FileType('rb'))
parser.add_argument('code', nargs=1, type=argparse.FileType('rb'))
parser.add_argument('flash_out', nargs=1, type=argparse.FileType('wb'))
args = parser.parse_args()


def xor(b1, b2): 
    result = bytearray()
    for b1, b2 in zip(b1, b2):
        result.append(b1 ^ b2)
    return result


flash_image = args.flash_image[0].read()
tcm_ram_image = args.tcm_ram_image[0].read()
code = args.code[0].read()


xor_image = xor(tcm_ram_image[:len(code)], flash_image)


new_flash_part = xor(code, xor_image)
flash_end = flash_image[len(code):]


args.flash_out[0].write(new_flash_part)
args.flash_out[0].write(flash_end)
