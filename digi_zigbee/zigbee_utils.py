"""Basic functions to implement supported ZDOs on Digi Gateway."""

import struct
# import sys

# Import Digi xbee and socket modules
import xbee

from socket import *

# Globals
socket_timeout = 10
rec_buf_size = 255


class NetworkAddress:
    """Network Address."""

    cluster_id_req = 0x0000
    cluster_id_resp = 0x8000

    def __init__(self):
        """init."""
        pass

    def build_tx_payload(self, ieee_addr, trans_id=1, req_type=0):
        """Return formatted payload."""
        ieee_addr_lit_end = convert_digi_addr_to_lit_end(ieee_addr)
        trans_id_hex = struct.pack("B", trans_id)
        req_type_hex = struct.pack("B", req_type)
        payload = trans_id_hex + ieee_addr_lit_end + req_type_hex
        return payload

    def parse_rx_payload(self, response):
        """Parse partial response."""
        print "\nTansaction ID =", response[0].encode("hex")
        print "Status =", response[1].encode("hex")
        print "IEEE Address =", response[9:1:-1].encode("hex")
        print "Network Address =", response[11:9:-1].encode("hex")


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
    """Management Network Discovery.

    Not supported by current Digi firmware.
    """

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


class Zcl:
    """ZigBee Cluster Lib base class."""

    def __init__(self):
        """init."""
        pass

    def build_read_payload(self, attribute_id, trans_seq=1):
        """Return formatted payload."""
        # Set ZCL parameters
        frame_control = '\x00'  # fixed
        trans_seq_byte = chr(trans_seq % 255)  # 3 to '\x03'
        commmand_id = '\x00'  # 00 read
        # Form ZCL header
        zcl_header = frame_control + trans_seq_byte + commmand_id
        # Form ZCL payload
        zcl_payload = struct.pack("<H", attribute_id)

        # Form ZCL frame
        zcl_frame = zcl_header + zcl_payload
        return zcl_frame

    def parse_rx_payload(self, response):
        """Parse partial response."""
        # print "\nTansaction ID =", response[0].encode("hex")
        # print "Status =", response[1].encode("hex")
        # print "IEEE Address =", response[9:1:-1].encode("hex")
        # print "Network Address =", response[11:9:-1].encode("hex")
        print_raw_payload(response)


def print_network_address(zdo_socket, ieee_addr, opt_bitmask=0):
    """A test function."""
    broadcast_addr = "[00:00:00:00:00:00:ff:ff]!"
    i = NetworkAddress()
    endpoint = 0x00
    profile_id = 0x0000
    cluster_id = i.cluster_id_req
    dest_addr_tuple = (broadcast_addr, endpoint, profile_id, cluster_id,
                       opt_bitmask, 0)
    print "#" * 15, "Network Address Request and Response"
    print_addr_tuple(dest_addr_tuple)
    payload = i.build_tx_payload(ieee_addr)
    print "sendto..."
    zdo_socket.sendto(payload, 0, dest_addr_tuple)
    print "recvfrom..."
    rx_data, rx_addr_tuple = zdo_socket.recvfrom(rec_buf_size)
    print_raw_payload(rx_data)
    i.parse_rx_payload(rx_data)


def print_ieee_address(zdo_socket, network_addr):
    """A test function."""
    # broadcast_addr = "[00:00:00:00:00:00:ff:ff]!"
    i = IeeeAddress()
    endpoint = 0x00
    profile_id = 0x0000
    cluster_id = i.cluster_id_req
    dest_addr_tuple = (network_addr, endpoint, profile_id, cluster_id, 0, 0)
    print "#" * 15, "IEEE Address for", network_addr
    print_addr_tuple(dest_addr_tuple)
    payload = i.build_tx_payload(network_addr)
    zdo_socket.sendto(payload, 0, dest_addr_tuple)
    rx_data, rx_addr_tuple = zdo_socket.recvfrom(rec_buf_size)
    print_raw_payload(rx_data)
    i.parse_rx_payload(rx_data)


def print_neighbor_table(zdo_socket, addr_str):
    """Print full neighbor table of a given device. A test function."""
    n = NeighborTable()
    endpoint = 0x00
    profile_id = 0x0000
    cluster_id = n.cluster_id_req
    dest_addr_tuple = (addr_str, endpoint, profile_id, cluster_id, 0, 0)
    print "*" * 30, "Neighbor Table for", addr_str
    print_addr_tuple(dest_addr_tuple)
    next_index = 0
    while next_index != -1:
        payload = n.build_tx_payload(start_index=next_index)
        zdo_socket.sendto(payload, 0, dest_addr_tuple)
        rx_data, rx_addr_tuple = zdo_socket.recvfrom(rec_buf_size)
        print "Received information:"
        print_addr_tuple(rx_addr_tuple)
        print_raw_payload(rx_data)
        n.parse_rx_payload(rx_data)
        next_index = n.next_start_index(rx_data)


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
    while next_index == 0:  # next_index != -1 to print all entries
        payload = n.build_tx_payload(start_index=next_index)
        zdo_socket.sendto(payload, 0, dest_addr_tuple)
        rx_data, rx_addr_tuple = zdo_socket.recvfrom(rec_buf_size)
        print_raw_payload(rx_data)
        n.parse_rx_payload(rx_data)
        next_index = n.next_start_index(rx_data)


def print_addr_tuple(addr_tuple):
    """Print a Digi formatted address tuple."""
    print "Address tuple =  (Address:", addr_tuple[0], "Endpoint =",\
          hex(addr_tuple[1]), "Profile =", hex(addr_tuple[2]), "Cluster =",\
          hex(addr_tuple[3]), ")"


def print_raw_payload(rx_data):
    """Print raw received payload."""
    print "Raw payload:", rx_data.encode("hex")


def open_socket(src_endpoint, timeout=10, xbee_param=XBS_PROT_TRANSPORT):
    """Open a ZigBee socket and bind to src_endpoint.

    Return the socket object.
    """
    skt = socket(AF_XBEE, SOCK_DGRAM, xbee_param)
    bind_tuple = ("", src_endpoint, 0, 0, 0, 0)
    skt.bind(bind_tuple)
    skt.settimeout(timeout)
    return skt


def convert_digi_addr_to_lit_end(addr_str):
    r"""Convert Digi formatted address to a little endian string.

    Example: "[1234]!" to "\x34\x12"
    "[07:06:05:04:03:02:01:00]!" to "\x00\x01\x02\x03\x04\x05\x06\x07"
    """
    addr_stripped = addr_str.translate(None, '[]:!')
    addr_hex = addr_stripped.decode("hex")
    addr_lit_endian = addr_hex[::-1]
    return addr_lit_endian


def listen_print_any_zdo():
    """Listen for any incoming zdo messange and print."""
    skt = open_socket(0)
    i = 1
    while True:
        try:
            rx_data, rx_addr_tuple = skt.recvfrom(rec_buf_size)
        except timeout:
            print "Socket timeout #", i
            i += 1
        else:
            print rx_addr_tuple
            print rx_data.encode("hex")


def test_read_attributes():
    """Test function."""
    endpoint = 0x01  # 0x0a for Schneider 8600, 0x01 for Telkonet
    profile_id = 0x0104  # Home Automation Profile
    cluster_id = 0x0201  # Thermostat cluster
    zcl_socket = open_socket(endpoint)
    zcl_obj = Zcl()
    trans_seq = 0xab

    prompt = "0:exit, 1:read attributes>"
    key = 1
    while key != 0:
        try:
            key = input(prompt)
            if key == 0:
                break
            elif key == 1:
                mac_addr = input("Mac address (string):")
                attribute_id = input("Attribute id (integer):")
                tx_addr_tuple = (mac_addr, endpoint, profile_id, cluster_id)
                tx_payload = zcl_obj.build_read_payload(attribute_id,
                                                        trans_seq)
                print_raw_payload(tx_payload)
                count = zcl_socket.sendto(tx_payload, 0, tx_addr_tuple)
                print "TX count:", count
                rx_payload, rx_addr_tuple = zcl_socket.recvfrom(rec_buf_size)

                print_addr_tuple(rx_addr_tuple)
                print_raw_payload(rx_payload)
                # Example read response (data from recvfrom):
                # 0x18 (frame control)
                # 0xf (transaction sq number)
                # 0x1 (command id: read response)
                # 0x11 0x0 (attribute id)
                # 0x0 (status: success)
                # 0x29 (data type)
                # 0xd0 0x7 (attribute value = 0x07d6 = 2006 -> 20.06 Celcius)

            else:
                print "Wrong input key!"
        except timeout:
            print "Socket timeout"

    zcl_socket.close()


def test_zdos():
    """Test function."""
    zdo_socket = open_socket(0)
    # To enable Python-level ACKs
    # zdo_socket.setsockopt(XBS_SOL_EP, XBS_SO_EP_SYNC_TX, 1)
    prompt = "0:exit, 1:ieee address, 2:network address, " + \
             "3:neighbor table, 4:routing table >"
    key = 1
    while key != 0:
        try:
            key = input(prompt)
            if key == 0:
                break
            elif key == 1:
                network_addr = raw_input("Network Address (Digi format): ")
                print_ieee_address(zdo_socket, network_addr)
            elif key == 2:
                ieee_addr = raw_input("IEEE Address (Digi format): ")
                print_network_address(zdo_socket, ieee_addr)
            elif key == 3:
                addr = raw_input("IEEE or Network Address (Digi format): ")
                print_neighbor_table(zdo_socket, addr)
            elif key == 4:
                addr = raw_input("IEEE or Network Address (Digi format): ")
                print_routing_table(zdo_socket, addr)
            else:
                print "\nWrong key!"
        except timeout:
            print "Socket timeout"
    zdo_socket.close()

# Run main
if __name__ == '__main__':
    test_read_attributes()
