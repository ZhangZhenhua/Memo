
memtable entry                                   

seq 64bit, 0-7 type, highest 56 bit is real seq no.
+---------+--------+------+-----------+----------+
| key_size| key    |seq   |val_size   |val       |
+---------+--------+------+-----------+----------+


log:
block size: kBlockSize , 32768=2^16.
log_header: hecksum (4 bytes), length (2 bytes), type (1 byte)
+-----+-------------+-----------+-------------------+
| CRC |record_length| RecordType| record            |
+-----+-------------+-----------+-------------------+
|<-4->| <----2----> | <---1---> |<--record_length-->|

record: retrived from writebatch.rep_, they are same     
+-----------+--------+------+----------+-----------+
|kTypeValue |key_size|key   |value_size| value     |
+-----------+--------+------+----------+-----------+

Compaction:
Pick: VersionSet::PickCompaction()
compaction_score_:
on level0:
	= num_of_level_0_files / kL0_CompactionTrigger(default 4)	
other levels:
	= total_bytes_of_level# / MaxBytesForLevel#

	MaxBytesForLevel#, level1=10M, level(i)=10M*i*10.


file_to_compact_:
	comments explaining in version_set.cc::680
	sigle file is default to 2M size, allowed_seeks is 128,
	allowed_seeks = max((f->file_size / 16384), 100)
	In get, if lookup one file, which means the key fall in the range
	holed by this file, but can't find the key. Punish it by reducing
	its allowed_seeks.

	In fact, it only punish the last missing file. WHY? it may help
	reducing number of lookups for next time for the same key. If
	punishing the first missing file, then user lookup the same key,
	it might still need lookup as many times as last time. We never
	know what user will get for the next time, but we do our best.
	Also, compacting the last level will provide more accuracy when
	searching this level.


DBImpl::DoCompactionWork

table_build->block_builder

block_builder::add(key, value)
DATA BLOCK:
KV-record:
+---------+------------+-----------+--------------+-----------+
| shared  | non-shared | value_size|non-shared-key|value      |
+---------+------------+-----------+--------------+-----------+

block, 4K at minimum.

restarts-array records offset within this data block.
 +-------------+-------+-----------+--------------+-------------+--------+
 | KV-record-1 |.....  |KV-record-N|restarts-array|restarts-size|trailer |
 +-------------+-------+-----------+--------------+-------------+--------+
 |     <-------------------    CRC32    ------------------->    |
                                                               

trailer:
+-----------------+--------+
|  CompressionType|CRC32   |
+-----------------+--------+

INDEX BLOCK:
Index block follows same format of data block, is composed by a set of KV
pairs, one for each data block.
 {key = last_key_successor, value = data_blockhandle }
 here the blockhandle is just an <offset/length> pair of the data block
 location in this sst file.

So the whole sst file is arranged by
+-------------+------+---------------+-----------------+-----------+------+
|data-block-1 |......|  data-block-2 |meta-index-block |index-block|footer|
+-------------+------+---------------+-----------------+-----------+------+

Open questions:
1. does range overlap between levels?
A: Yes, it does.

2. What's meta-index-block?
A: Seems now only bloom-filter is using that block for some metadata, which
   I havn't touched. Might add later.
