function [mac_str, mac_num] = getMacAddress
    localhost = java.net.InetAddress.getLocalHost;
    networkinterface = java.net.NetworkInterface.getByInetAddress(localhost);
    mac_num = typecast(networkinterface.getHardwareAddress, 'uint8');
    
    m_dec = cellstr(dec2hex(mac_num));
    mac_str = [sprintf('%s-', m_dec{1:end - 1}), m_dec{end}];
    
end
