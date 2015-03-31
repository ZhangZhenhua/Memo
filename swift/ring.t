

RingData:
	devs = []
	_replica2part2dev_id = []
	_part_shift

	
RingBuilder:
	part_power # <32
	replicas #number of replicas for each partition, >=1
	min_part_hours #minimum number of hours between partition changes
	parts = 2**part_power
	devs = []
	devs_changed=False
	version
	overload = 0.0
	_replica2part2dev_id = []

	_last_part_moves_epoch 
	_last_part_moves 
	_last_part_gather_start 
	_dispersion_graph = {}
	dispersion = 0.0
	_remove_devs = []
	_ring 


dev{}   # builder.py::254, element in devs[]
	id
	weight
	region
	zone
	ip
	port
	device
	meta

	parts_wanted #builder.py::_set_parts_wanted, add_dev/remove_dev



_replica2part2dev_id  #using three copies as example
	[part2dev_array1, part2dev_array2, part2dev_array3]
	





serialize_v1:

Magic = "RING"
Version = 1
+-----+--------+-----+------------+-------------+-------------+--------+
|Magic| Version| devs| part_shift |replica_count| part2dev_len|part2dev|
+-----+--------+-----+------------+-------------+-------------+--------+


QUESTIONS:
1. Why replicas can be fractional? like 2.25.

2. builder.py line 232-235
   devs = [None]*len(self.devs)
   devs[dev['id']] = dict(...)
   So dev['id'] is ranged from [ 0, len(self.devs) ), what if we remove one
   device and then add new one? dev['id'] might cross the board.

   Better to let ring detemine device::id, which is max(current)+1.
