#!/bin/bash
#
# ecb-mount.sh: Simple sanity check for setting ecb as cipher.
# Author: Zameer Manji <zmanji@gmail.com>
#
# Copyright (C) 2013 Zameer Manji
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation version 2
# of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA

test_script_dir=$(dirname $0)
rc=1

. ${test_script_dir}/../lib/etl_funcs.sh

test_cleanup()
{
	exit $rc
}
trap test_cleanup 0 1 2 3 15

# TEST

etl_add_keys || exit
etl_lmount || exit
default_mount_opts="rw,relatime,ecryptfs_cipher=aes,ecryptfs_cipher_mode=ecb,ecryptfs_key_bytes=16,ecryptfs_sig=\${ETL_FEKEK_SIG}"
etl_mount_i || exit
test_dir=$(etl_create_test_dir) || exit

rc=0

echo test > $test_dir/testfile
if [ $? -ne 0 ]; then
	rc=1
fi

cat $test_dir/testfile > /dev/null
if [ $? -ne 0 ]; then
	rc=1
fi

rm $test_dir/testfile
if [ $? -ne 0 ]; then
	rc=1
fi

exit
