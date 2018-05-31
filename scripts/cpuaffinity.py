
import procfs
import schedutils


def convert_to_range(num_list):
    num_list.sort()
    range_list = []
    range_min = num_list[0]
    for num in num_list:
        next_val = num + 1
        if next_val not in num_list:
            if range_min != num and (range_min + 1) != num:
                range_list.append(str(range_min) + '-' + str(num))
            else:
                range_list.append(str(range_min))
                if range_min != num:
                    range_list.append(str(num))
            next_index = num_list.index(num) + 1
            if next_index < len(num_list):
                range_min = num_list[next_index]
    return ','.join(range_list)


def get_affinity(ps_objs, threads=False, parent=''):
    if parent:
        parent += ' '
    for obj in ps_objs:
        pid = obj.pid
        comm = parent + obj["stat"]["comm"]
        aff = convert_to_range(schedutils.get_affinity(pid))
        print("pid %s's (%s) affinity is %s" % (pid, comm, aff))
        if not threads and 'threads' in obj:
            get_affinity(obj['threads'].values(), threads=True, parent=comm)


def main():
    ps = procfs.pidstats()
    ps.reload_threads()
    ps_objs = ps.values()
    get_affinity(ps_objs)


if __name__ == "__main__":
    main()
