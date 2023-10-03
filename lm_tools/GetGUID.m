function [ GUID ] = getGUID(  )
% Returns a globally unique ID

GUID=char(java.util.UUID.randomUUID());
end

