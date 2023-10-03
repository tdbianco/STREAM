%% Stream Error Type
%
% Defines the error type occured during a stream.
%
%%
classdef StreamErrorType < int32
   enumeration
      %% ConnectionLost 
      % Indicates that the connection to the device was lost.
      %
      %     type.ConnectionLost (0)
      %
      ConnectionLost  (0)
      %%
      %% InsufficientLicense
      % Indicates that a feature locked by license is trying to be used.
      %
      %     type.InsufficientLicense (1)
      %
      InsufficientLicense (1)
      %%
      %% NotSupported 
      % Indicates that a feature not supported by the device is trying to
      % be used.
      %
      %     type.NotSupported  (2)
      %
      NotSupported (2)
      %%
      %% Internal 
      % Indicates that an internal error occured during a stream.
      %
      %     type.Internal  (3)
      %
      Internal (3)
      %%
      %% User 
      % Indicates that an error reported by the user occured during a stream.
      %
      %     type.User  (4)
      %
      User (4)
      %%
   end
end

%% Version
% !version
%
% COPYRIGHT !year - PROPERTY OF TOBII AB
% Copyright !year TOBII AB - KARLSROVAGEN 2D, DANDERYD 182 53, SWEDEN - All Rights Reserved.
%
% Copyright NOTICE: All information contained herein is, and remains, the property of Tobii AB and its suppliers,
% if any. The intellectual and technical concepts contained herein are proprietary to Tobii AB and its suppliers and
% may be covered by U.S.and Foreign Patents, patent applications, and are protected by trade secret or copyright law.
% Dissemination of this information or reproduction of this material is strictly forbidden unless prior written
% permission is obtained from Tobii AB.
%