"""Basic functions to implement supported ZDOs on Digi Gateway."""

# Import Digi xbee and socket modules
import xbee
from socket import *
import struct

# Globals
socket_timeout = 5


def print_recv_payload(rx_data):
    """Print returned payload from a call to recvfrom."""
    print "Payload =",
    #  for i in range(len(rx_data)):
    for byte in rx_data:
        print hex(ord(byte)),
    print


def print_addr_tuple(addr_tuple):
    """Print a Digi formatted address tuple."""
    print "\nReceived address tuple:"
    print "Address =", rx_addr_tuple[0]
    print "Endpoint =", hex(rx_addr_tuple[1])
    print "Profile =", hex(rx_addr_tuple[2])
    print "Cluster =", hex(rx_addr_tuple[3])


def open_and_bind_socket(src_endpoint, xbee_param=XBS_PROT_TRANSPORT):
    """Open a ZigBee socket and bind to src_endpoint.

    Return the socket object.
    """
    skt = socket(AF_XBEE, SOCK_DGRAM, xbee_param)
    bind_tuple = ("", src_endpoint, 0, 0, 0, 0)
    skt.bind(bind_tuple)
    return skt


def convert_digi_addr_to_lit_end(addr_str):
    r"""Convert Digi formatted address to a little endian hex string.

    Example: "[fffe]!" to "\xfe\xff"
    """
    addr_stripped = addr_str.translate(None, '[]:!')
    addr_hex = addr_stripped.decode("hex")
    addr_lit_endian = addr_hex[::-1]
    return addr_lit_endian


def send_ieee_address_req(zdo_socket, trans_id, network_addr, req_type=0):
    """Send IEEE address request.

    trans_id: integer 0 to 255
    network_addr_str: Digi format. Example: '[f07a]!'
    """
    network_addr_lit_end = convert_digi_addr_to_lit_end(network_addr)
    trans_id_hex = struct.pack("B", trans_id)
    req_type_hex = struct.pack("B", req_type)
    payload = trans_id_hex + network_addr_lit_end + req_type_hex
    for t in payload:
        print hex(ord(t))
    # Form destination address tuple
    broadcast_addr = "[00:00:00:00:00:00:ff:ff]!"  # '[fffe]!'

    endpoint = 0x00  # Device profile endpoint
    profile_id = 0x0000  # Device profile
    cluster_id = 0x0001  # IEEE addr request
    dest_addr_tuple = (broadcast_addr, endpoint, profile_id, cluster_id, 0, 0)
    # Transmit
    zdo_socket.sendto(payload, 0, dest_addr_tuple)


def send_neighbor_table_req(zdo_socket, trans_id, addr_str, start_index=0):
    """Send neighbor table request.

    trans_id: integer 0 to 255
    start_index: integer 0 to 255
    addr_str: Digi format. Examples: '[f07a]!' and '00:1d:35:08:03:24:37:91!'
    """
    payload = struct.pack("BB", trans_id, start_index)
    # Form destination address tuple
    endpoint = 0x00  # Device profile endpoint
    profile_id = 0x0000  # Device profile
    cluster_id = 0x0031  # Neighbor table request
    dest_addr_tuple = (addr_str, endpoint, profile_id, cluster_id, 0, 0)
    # Transmit the request
    zdo_socket.sendto(payload, 0, dest_addr_tuple)


def print_partial_neighbor_table(rx_data):
    """Parse and print."""
    print "\nTansaction ID =", rx_data[0].encode("hex")
    print "Status =", rx_data[1].encode("hex")
    print "Neighbor Table Entries =", rx_data[2].encode("hex")
    print "Start Index =", rx_data[3].encode("hex")
    print "Neighbor Table List Count =", rx_data[4].encode("hex")
    # "\x00\x13\xa2\x00\x40\xd4\x69\x97"
    # "\x00\x01\x02\x03\x04\x05\x06\x07"
    offset = 5
    for i in range(ord(rx_data[4])):
        neighbor_table = rx_data[offset:]
        print
        print "Extended PAN ID =", neighbor_table[7::-1].encode("hex")
        print "IEEE Address =", neighbor_table[15:7:-1].encode("hex")
        print "Network Address =", neighbor_table[17:15:-1].encode("hex")
        print "Bit fields =", neighbor_table[18:20].encode("hex")
        print "Depth = ", neighbor_table[20].encode("hex")
        print "LQI = ", neighbor_table[21].encode("hex")
        offset += 22
    return ord(rx_data[4])


def print_full_neighbor_table(zdo_socket, addr_str):
    """Iterate through neighbor table and print all entries."""
    trans_id = 1
    start_index = 0
    repeat = True
    while (repeat):
        send_neighbor_table_req(zdo_socket, trans_id, addr_str, start_index)
        try:
            rx_data, rx_addr_tuple = zdo_socket.recvfrom(255)
        except:
            print "Exception on recvfrom"
        else:
            print_partial_neighbor_table(rx_data)
            total_entries = ord(rx_data[2])
            list_count = ord(rx_data[4])
            repeat = (total_entries != start_index + list_count)
            start_index = list_count


def test():
    """Test function."""
    skt = open_and_bind_socket(0)
    skt.settimeout(socket_timeout)
    addr = '[0000]!'
    print_full_neighbor_table(skt, addr)
    # send_ieee_address_req(skt, trans_id, addr)
    skt.close()
