classdef teServer < teNetwork
    
    properties 
        Port = 3000
    end
    
    properties (Dependent, SetAccess = private)
        ClientDetails
    end
    
    properties (Access = private)
        prSocket 
        prConns = []
        prNetTimer
        prIsShutdown = false
        prClientIP = {}
        prClientPort = []
        prClientUser = {}
    end
    
    properties (Constant)
        CONST_timerRate = .01
    end
    
    events
        RemoteExecute
    end
    
    methods
        
        function obj = teServer
            
            % check for pnet 
            if isempty(which('pnet'))
                error('This class requires the ''pnet'' library.')
            end

            % create a TCP/IP socket
            obj.prSocket = pnet('tcpsocket', obj.Port);
            
            % set up timer
            obj.prNetTimer = timer(...
                'Period', obj.CONST_timerRate,...
                'ExecutionMode', 'fixedRate',...
                'TimerFcn', @obj.HandleNetwork,...
                'BusyMode', 'drop');
            start(obj.prNetTimer)
            
        end
        
        function ShutDown(obj)
            stop(obj.prNetTimer)
            delete(obj.prNetTimer)
            pnet('closeall')   
            obj.prIsShutdown = true;
        end
        
        function delete(obj)
            if ~obj.prIsShutdown, obj.ShutDown, end
        end

        function HandleNetwork(obj, ~, ~)
        % handles all network communication. Called by a timer at a certain
        % interval. Checks for connection requests, and for database
        % requests from connected clients. All requests are responded to
        % immediately if possible
                       
            % handle connection requests
            obj.HandleNewNetworkConnections
            
            % handle protocol messages for all connections
            obj.HandleNetworkProtocol
            
        end
        
        function HandleNetworkProtocol(obj)
        % loops through all connections and checks for protocol requests,
        % then handles these
        
            numConnections = length(obj.prConns);
            for c = 1:numConnections 
                                
                % check buffer
                res = pnet(obj.prConns(c), 'readline', 'noblock');
                
%                 if isempty(res)
%                     fprintf('No data (empty) from connection %d\n', c);
%                 elseif strcmpi(res, '')
%                     fprintf('No data (empty string) from connection %d\n', c);
%                 elseif isequal(res, -1)
%                     fprintf('Error (res was -1) checking connection %d\n', c)
%                 else
%                     fprintf('Data from %d was: %s\n', c, res)
%                 end
                
                if isempty(res) || isequal(res, -1)
                    % no messages from this connection, move on
                    continue
                end
                    
                % take first word of protocol message - this is the
                % command
                parts = strsplit(res, ' ');
                cmd = parts{1};

                % data is any subsequent words
                if length(parts) > 1
                    data = parts(2:end);
                else
                    data = [];
                end
                
                % send READY
                                
                switch cmd
                    
                    case 'USER'
                        obj.prClientUser{c} = data{1};
                        obj.AddLog(sprintf('Client [%s] is user [%s]\n',...
                            obj.prClientIP{c}, obj.prClientUser{c}));
                        obj.netSendReady(obj.prConns(c));
                        
                    otherwise
                        % fire event
                        ev = teEvent(cmd, data);
                        notify(obj, 'RemoteExecute', ev);
                        
                        % log
                        obj.AddLog(sprintf('Fired event for remote execution: %s\n', res));
                        obj.netSendReady(obj.prConns(c));
                        
                end
                
            end
            
        end
          
        function HandleNewNetworkConnections(obj)
        % polls for new TCP/IP connections from clients, and initiates them
            
            % check for new connections
            res = pnet(obj.prSocket, 'tcplisten', 'noblock');
            
            if res ~= -1
                
                % store connection handle in array
                obj.prConns(end + 1) = res;   
                
                % set read timeout to default
                pnet(obj.prConns(end), 'setreadtimeout',...
                    obj.CONST_ReadTimeout)
                
                % get IP and port of client
                [ip_client, port_client] = pnet(obj.prConns(end), 'gethost');
                
                % convert IP vector to string
                ip_client = sprintf('%d.', ip_client);
                ip_client(end) = [];
                
                % store
                obj.prClientIP{res} = ip_client;
                obj.prClientPort(res) = port_client;
                obj.prClientUser{res} = 'unknown';
                
                obj.AddLog('Client connected on %s\n', obj.ClientDetails{res});
                
            end
            
        end
        
        function val = get.ClientDetails(obj)
            
            % get number of users 
            numUsers = length(obj.prClientIP);
            
            if numUsers == 0
                % if no users, return empty
                val = [];
                
            else
                % loop through users and build string of 'IP:port (user)'
                val = cell(numUsers, 1);
                for u = 1:numUsers
                    if ~isempty(obj.prClientUser{u})
                        % is username is available, use it...
                        val{u} = sprintf('%s:%d (%s)', obj.prClientIP{u},...
                            obj.prClientPort(u), obj.prClientUser{u});
                        
                    else
                        % ...otherwise just use IP and port
                        val{u} = sprintf('%s:%d', obj.prClientIP{u},...
                            obj.prClientPort(u));
                    end
                end
            end
        end
                
    end
    
end