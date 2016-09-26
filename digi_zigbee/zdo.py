"""Basic functions to implement supported ZDOs on Digi Gateway."""

# Import Digi xbee and socket modules
import xbee
from socket import *
import struct
import sys

# Globals
socket_timeout = 10


def print_addr_tuple(addr_tuple):
    """Print a Digi formatted address tuple."""
    print "\nAddress tuple:"
    print "Address =", addr_tuple[0]
    print "Endpoint =", hex(addr_tuple[1])
    print "Profile =", hex(addr_tuple[2])
    print "Cluster =", hex(addr_tuple[3])


def print_raw_payload(rx_data):
    """Print raw received payload."""
    print "\nRaw received payload:", rx_data.encode("hex")


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

    Example: "[1234]!" to "\x34\x12"
    "[07:06:05:04:03:02:01:00]!" to "\x00\x01\x02\x03\x04\x05\x06\x07"
    """
    addr_stripped = addr_str.translate(None, '[]:!')
    addr_hex = addr_stripped.decode("hex")
    addr_lit_endian = addr_hex[::-1]
    return addr_lit_endian


class IeeeAddress:
    """IEEE Address."""

    cluster_id_req = 0x0001
    cluster_id_resp = 0x8001

    def __init__(self):
        """init."""
        pass

    def build_tx_payload(self, network_addr, trans_id=1, req_type=0):
        """Return formatted payload."""
        network_addr_lit_end = convert_digi_addr_to_lit_end(network_addr)
        trans_id_hex = struct.pack("B", trans_id)
        req_type_hex = struct.pack("B", req_type)
        payload = trans_id_hex + network_addr_lit_end + req_type_hex
        print "\nPayload =", payload.encode("hex")
        return payload

    def parse_rx_payload(self, response):
        """Parse partial response."""
        print "\nTansaction ID =", response[0].encode("hex")
        print "Status =", response[1].encode("hex")
        print "IEEE Address =", response[9:1:-1].encode("hex")
        print "Network Address =", response[11:9:-1].encode("hex")


class NeighborTable:
    """Neighbor Table."""

    cluster_id_req = 0x0031
    cluster_id_resp = 0x8031

    def __init__(self):
        """init."""
        pass

    def build_tx_payload(self, trans_id=1, start_index=0):
        """Return formatted payload."""
        payload = struct.pack("BB", trans_id, start_index)
        print "\nPayload =", payload.encode("hex")
        return payload

    def parse_rx_payload(self, response):
        """Parse partial response."""
        print "\nTansaction ID =", response[0].encode("hex")
        print "Status =", response[1].encode("hex")
        print "Neighbor Table Entries =", response[2].encode("hex")
        print "Start Index =", response[3].encode("hex")
        print "Neighbor Table List Count =", response[4].encode("hex")
        offset = 5
        for i in range(ord(response[4])):
            item = response[offset:]
            print
            print "Extended PAN ID =", item[7::-1].encode("hex")
            print "IEEE Address =", item[15:7:-1].encode("hex")
            print "Network Address =", item[17:15:-1].encode("hex")
            print "Bit fields =", item[18:20].encode("hex")
            print "Depth = ", item[20].encode("hex")
            print "LQI = ", item[21].encode("hex")
            offset += 22

    def next_start_index(self, response):
        """Return next start index if there is one o.w. None."""
        total = ord(response[2])
        start_index = ord(response[3])
        current = ord(response[4])
        if total > start_index + current:
            result = start_index + current
        else:
            result = -1
        return result


class RoutingTable:
    """Management Routing Table."""

    cluster_id_req = 0x0032
    cluster_id_resp = 0x8032

    def __init__(self):
        """init."""
        pass

    def build_tx_payload(self, trans_id=1, start_index=0):
        """Return formatted payload."""
        payload = struct.pack("BB", trans_id, start_index)
        print "\nPayload =", payload.encode("hex")
        return payload

    def parse_rx_payload(self, response):
        """Parse partial response."""
        print "\nTansaction ID =", response[0].encode("hex")
        print "Status =", response[1].encode("hex")
        print "Routing Table Entries =", response[2].encode("hex")
        print "Start Index =", response[3].encode("hex")
        print "Routing Table List Count =", response[4].encode("hex")
        offset = 5
        for i in range(ord(response[4])):
            item = response[offset:]
            print
            print "Destination Address =", item[1::-1].encode("hex")
            print "Status and flags =", item[2].encode("hex")
            print "Next-hop Address =", item[4:2:-1].encode("hex")
            offset += 5

    def next_start_index(self, response):
        """Return next start index if there is one o.w. None."""
        total = ord(response[2])
        start_index = ord(response[3])
        current = ord(response[4])
        if total > start_index + current:
            result = start_index + current
        else:
            result = -1
        return result


class MngmtNetDiscovery:
    """Management Network Discovery."""

    cluster_id_req = 0x0030
    cluster_id_resp = 0x8030

    def __init__(self):
        """init."""
        pass

    def build_payload(self, trans_id=1, scan_channels=0x07FFF800,
                      scan_time=0x01, start_index=0):
        """Return formatted payload."""
        payload = struct.pack("<BIBB", trans_id, scan_channels, scan_time,
                              start_index)
        print "\nPayload =", payload.encode("hex")
        return payload

    def parse_payload(self, response):
        """Parse partial response."""
        print "\nTansaction ID =", response[0].encode("hex")
        print "Status =", response[1].encode("hex")
        print "Network Count =", response[2].encode("hex")
        print "Start Index =", response[3].encode("hex")
        print "Network List Count =", response[4].encode("hex")
        offset = 5
        for i in range(ord(response[4])):
            item = response[offset:]
            print
            print "Extended PAN ID =", item[7::-1].encode("hex")
            print "Channel =", item[8].encode("hex")
            print "Stack and ZigBee =", item[9].encode("hex")
            print "Beacon and Superframe =", item[10].encode("hex")
            print "Permit join and reserved = ", item[11].encode("hex")
            offset += 12

    def next_start_index(self, response):
        """Return next start index if there is one o.w. None."""
        total = ord(response[2])
        start_index = ord(response[3])
        current = ord(response[4])
        if total > start_index + current:
            result = start_index + current
        else:
            result = -1
        return result


def print_neighbor_table(zdo_socket, addr_str):
    """Print full neighbor table of a given device. A test function."""
    n = NeighborTable()
    endpoint = 0x00
    profile_id = 0x0000
    cluster_id = n.cluster_id_req
    dest_addr_tuple = (addr_str, endpoint, profile_id, cluster_id, 0, 0)
    print "*" * 15, "Neighbor Table for", addr_str
    print_addr_tuple(dest_addr_tuple)
    next_index = 0
    while next_index != -1:
        payload = n.build_tx_payload(start_index=next_index)
        zdo_socket.sendto(payload, 0, dest_addr_tuple)
        rx_data, rx_addr_tuple = zdo_socket.recvfrom(255)
        print_raw_payload(rx_data)
        n.parse_rx_payload(rx_data)
        next_index = n.next_start_index(rx_data)


def print_ieee_address(zdo_socket, network_addr):
    """A test function."""
    broadcast_addr = "[00:00:00:00:00:00:ff:ff]!"
    i = IeeeAddress()
    endpoint = 0x00
    profile_id = 0x0000
    cluster_id = i.cluster_id_req
    dest_addr_tuple = (broadcast_addr, endpoint, profile_id, cluster_id, 0, 0)
    print "#" * 15, "IEEE Address for", network_addr
    print_addr_tuple(dest_addr_tuple)
    payload = i.build_tx_payload(network_addr)
    zdo_socket.sendto(payload, 0, dest_addr_tuple)
    rx_data, rx_addr_tuple = zdo_socket.recvfrom(255)
    print_raw_payload(rx_data)
    i.parse_rx_payload(rx_data)


def print_routing_table(zdo_socket, addr_str):
    """Test function."""
    n = RoutingTable()
    endpoint = 0x00
    profile_id = 0x0000
    cluster_id = n.cluster_id_req
    dest_addr_tuple = (addr_str, endpoint, profile_id, cluster_id, 0, 0)
    print ">" * 15, "Routing Table for", addr_str
    print_addr_tuple(dest_addr_tuple)
    next_index = 0
    while next_index == 0:
        payload = n.build_tx_payload(start_index=next_index)
        zdo_socket.sendto(payload, 0, dest_addr_tuple)
        rx_data, rx_addr_tuple = zdo_socket.recvfrom(255)
        print_raw_payload(rx_data)
        n.parse_rx_payload(rx_data)
        next_index = n.next_start_index(rx_data)


def test():
    """Test function."""
    zdo_socket = open_and_bind_socket(0, xbee_param=XBS_PROT_APS)
    zdo_socket.settimeout(socket_timeout)
    network_addr_list = ['0000!', '[762a]!', '[c38f]!']
    # ['[0000]!', '[8927]!', '[b7bb]!', '[050f]!']
    for addr_str in network_addr_list:
        try:
            print_ieee_address(zdo_socket, addr_str)
            print_neighbor_table(zdo_socket, addr_str)
            print_routing_table(zdo_socket, addr_str)
        except timeout:
            print "Socket timeout for", addr_str
    zdo_socket.close()

# Run main
if __name__ == '__main__':
    test()
