#!/bin/bash
#
# cipher-mode-white-list.sh: Simple sanity check for cipher mode white listing.
# Author: Alvin Tran <althaitran@gmail.com>
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
  etl_remove_test_dir $test_dir
  etl_umount
  etl_lumount
  etl_unlink_keys
	exit $rc
}
trap test_cleanup 0 1 2 3 15

# TEST

etl_add_keys || exit
etl_lmount || exit


#Try to mount with a valid cipher mode not in the white list (should fail)
default_mount_opts="rw,relatime,ecryptfs_cipher=aes,ecryptfs_cipher_mode=xts,ecryptfs_key_bytes=16,ecryptfs_sig=\${ETL_FEKEK_SIG}"
default_fne_mount_opts="${default_mount_opts},ecryptfs_fnek_sig=\${ETL_FNEK_SIG}"
rc=0

export ETL_MOUNT_OPTS=$(eval "echo $default_mount_opts")
etl_mount_i

if [ $? -eq 0 ]; then
	rc=1
fi

#Try to mount with an invalid cipher mode (should fail)
default_mount_opts="rw,relatime,ecryptfs_cipher=aes,ecryptfs_cipher_mode=test,ecryptfs_key_bytes=16,ecryptfs_sig=\${ETL_FEKEK_SIG}"
default_fne_mount_opts="${default_mount_opts},ecryptfs_fnek_sig=\${ETL_FNEK_SIG}"
rc=0

export ETL_MOUNT_OPTS=$(eval "echo $default_mount_opts")
etl_mount_i

if [ $? -eq 0 ]; then
	rc=1
fi

#Try to mount with a valid cipher mode in the white list (should pass)
default_mount_opts="rw,relatime,ecryptfs_cipher=aes,ecryptfs_cipher_mode=cbc,ecryptfs_key_bytes=16,ecryptfs_sig=\${ETL_FEKEK_SIG}"
default_fne_mount_opts="${default_mount_opts},ecryptfs_fnek_sig=\${ETL_FNEK_SIG}"
rc=0

export ETL_MOUNT_OPTS=$(eval "echo $default_mount_opts")
etl_mount_i

if [ $? -ne 0 ]; then
	rc=1
fi

exit
