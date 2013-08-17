#!/usr/bin/ruby -w
# coding: UTF-8
#
#

utf8_string="foo一bar"
gbk_string=utf8_string.encode("GBK")
gbk_sub_dir1="foo一bar/哈哈哈".encode("GBK")
gbk_sub_dir2="foo一bar/哈哈".encode("GBK")
gbk_sub_file1="foo一bar/哈哈哈/二.jpg".encode("GBK")
gbk_sub_file2="foo一bar/哈哈/二.avi".encode("GBK")
gbk_sub_file3="foo一bar/哈哈/招聘.avi".encode("GBK")

require 'fileutils'
FileUtils.mkdir_p gbk_string
FileUtils.mkdir_p gbk_sub_dir1
FileUtils.mkdir_p gbk_sub_dir2
FileUtils.touch gbk_sub_file1
FileUtils.touch gbk_sub_file2
FileUtils.touch gbk_sub_file3
FileUtils.touch "后缀不正确文件.png".encode("GBK")

