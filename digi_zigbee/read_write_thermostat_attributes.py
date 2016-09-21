#
# This codes serves as a simple tutorial for using ZigBee Cluster Lib (ZCL) to read and write attributes of 
# a Schneider 8600 room controller from a Digi Gateway
# For information refer to ZIGBEE CLUSTER LIBRARY SPECIFICATION (ZigBee Alliance)
#

# Prints received response: data and address
def print_recv_response(rx_data, rx_addr_tuple):
    print "Received address tuple =", rx_addr_tuple
    print "Endpoint =", hex(rx_addr_tuple[1])
    print "Profile =", hex(rx_addr_tuple[2])
    print "Cluster =", hex(rx_addr_tuple[3])
    print "Received payload =", rx_data
    for i in range(len(rx_data)):
        print hex(ord(rx_data[i]))


# Import Digi xbee and socket modules
import xbee
from socket import *


# Open a socket and bind to an endpoint to use for read/write
skt = socket(AF_XBEE, SOCK_DGRAM, XBS_PROT_TRANSPORT)
src_endpoint = 0x20 # Arbitrary endpoint
bind_tuple = ("", src_endpoint, 0, 0, 0, 0)
skt.bind(bind_tuple)

# Form destination address tuple
profile_id = 0x0104 # Home Automation Profile
endpoint = 0x0a # Thermostat device endpoint on Schneider 8600
cluster_id = 0x0201 # Thermostat cluster
# Mac address (formmatted) for a thermostat on Digi gateway's ZigBee network
thermostat_mac_address = "00:1d:35:08:03:16:99:92!" 
destination_address_tuple = (thermostat_mac_address, endpoint, profile_id, cluster_id, 0, 0)


#------------------------------Read the value of an attribute (occupied cool setpoint)
# Set ZCL parameters
frame_control = '\x00' # fixed
transaction_seq_num = '\x0f' # arbitrary 8-bit number
commmand_id = '\x00' # 00 read, 02 write
# Occupied cool setpoint: attribute id = 0x0011
attribute_id = '\x11\x00' # bytestring, little endian

# Form ZCL header
zcl_header = frame_control + transaction_seq_num + commmand_id

# Form ZCL payload
zcl_payload = attribute_id

# Form ZCL frame
zcl_frame = zcl_header + zcl_payload

# Send the ZCL command
count = skt.sendto(zcl_frame, 0, destination_address_tuple)

# Receive the response
rx_data, rx_addr_tuple = skt.recvfrom(255) 

# Print the response
print_recv_response(rx_data, rx_addr_tuple)

# Example read response (data from recvfrom): 
# 0x18 (frame control) 0xf (transaction sq number) 0x1 (command id: read response) 
# 0x11 0x0 (attribute id) 0x0 (status: success) 0x29 (data type) 
# 0xd0 0x7 (attribute value = 0x07d6 = 2006 -> 20.06 Celcius)


#----------------------------Write a value to an attribute (occupied cool setpoint)
# Set ZCL parameters
frame_control = '\x00' #
transaction_seq_num = '\x0f' # arbitrary 8-bit number
commmand_id = '\x02' # 00 read, 02 write

# Form ZCL header
zcl_header = frame_control + transaction_seq_num + commmand_id

# Form ZCL payload
# Occupied cool setpoint: attribute id = 0x0011
attribute_id = '\x11\x00' # bytestring, little endian
attribute_data_type = '\x29' # indicates 16-bit signed integer 
attribute_data = '\xb8\x0b' # 0x0bb8 = 3000 -> 30.00 degrees (celcius)
zcl_payload = attribute_id + attribute_data_type + attribute_data

# Form ZCL frame
zcl_frame = zcl_header + zcl_payload

# Send the ZCL command
count = skt.sendto(zcl_frame, 0, destination_address_tuple)

# Receive the response
rx_data, rx_addr_tuple = skt.recvfrom(255) # refer to Digi XBee API

# Print the response
print_recv_response(rx_data, rx_addr_tuple)

# Example write response (data from recvfrom): 
# 0x18 (frame control) 0xf (transaction sq number) 0x4 (write attributes response) 
# 0x0 (status: successful)



#-------------------------Finish up
# Close socket
skt.close()



