% Define simulation parameters
numNodes = 10;
simulationTime = 10; % in seconds

% Initialize nodes and network parameters
nodes = initializeNodes(numNodes);

% Initialize arrays to store simulation data
channelStatus = zeros(1, simulationTime);
transmissionRates = zeros(numNodes, simulationTime);
collisionCount = zeros(1, simulationTime);
latency = zeros(1, numNodes); % Array to store latency values for each node

% Main simulation loop
for t = 1:simulationTime
    % Simulate channel conditions and environmental changes
    channelStatus(t) = simulateChannelConditions(); % Store channel status
    
    % Execute modules
    [collisionCount(t), latency] = opportunisticAccess(nodes, t, latency); % Store collision count and latency
    hiddenNodeMitigation(nodes);
    
    multiObjectiveAutoRateTransmission(nodes);
    
    % Store transmission rates of nodes
    for i = 1:numNodes
        transmissionRates(i, t) = nodes(i).TransmissionRate;
    end
    
    % Display simulation progress
    fprintf('Simulation time step: %d/%d\n', t, simulationTime);
    
    % Compute and display average collision count and average latency up to this time step
    avgCollisionCount = mean(collisionCount(1:t));
    avgLatency = mean(latency);
    fprintf('Average Collision Count up to time step %d: %.2f\n', t, avgCollisionCount);
    fprintf('Average Latency up to time step %d: %.2f\n', t, avgLatency);
end

% Compute average collision count and average latency
avgCollisionCount = mean(collisionCount);
avgLatency = mean(latency);

% Display average collision count and average latency
fprintf('Average Collision Count: %.2f\n', avgCollisionCount);
fprintf('Average Latency: %.2f seconds\n', avgLatency);

% Plot collision rate versus time
timeSteps = 1:simulationTime;
collisionRate = collisionCount ./ numNodes; % Calculate collision rate
plot(timeSteps, collisionRate, '-o');
title('Collision Rate vs Time');
xlabel('Time (seconds)');
ylabel('Collision Rate');
grid on;

% Function to initialize nodes
function nodes = initializeNodes(numNodes)
    % Define the area of the network
    areaWidth = 100; % Define the width of the area
    areaHeight = 100; % Define the height of the area
    
    % Initialize an array to store node information
    nodes = struct('ID', {}, 'Position', {}, 'TransmissionPower', {}, 'TransmissionRate', {});
    
    % Loop to initialize each node
    for i = 1:numNodes
        % Generate random position for each node within the defined area
        x = rand * areaWidth;
        y = rand * areaHeight;
        
        % Generate random transmission power for each node (for example, between 1 and 10)
        transmissionPower = randi([1, 10]);
        
        % Assign a unique ID to each node
        node.ID = i;
        
        % Store node information in the structure array
        nodes(i) = struct('ID', node.ID, 'Position', [x, y], 'TransmissionPower', transmissionPower, 'TransmissionRate', 0);
    end
end

% Function to simulate channel conditions
function channelStatus = simulateChannelConditions()
    % Simulate channel conditions
    % For simplicity, let's randomly determine if the channel is idle or busy
    
    % Randomly generate a number between 0 and 1
    randomNum = rand();
    
    % Define threshold to determine channel status
    idleThreshold = 0.5; % Adjust as needed
    
    % Determine channel status based on the random number
    if randomNum < idleThreshold
        channelStatus = "idle";
    else
        channelStatus = "busy";
    end
end

% Function to simulate opportunistic access to the channel
function [collisionCount, latency] = opportunisticAccess(nodes, t, latency)
    % Simulate channel conditions
    channelStatus = simulateChannelConditions();
    
    % Initialize collision count and latency for this time step
    collisionCount = 0;
    latencyThisStep = 0;
    
    % Iterate through each node
    for i = 1:numel(nodes)
        % Check if the channel is idle
        if channelStatus == "idle"
            % Node opportunistically accesses the channel for data transmission
            fprintf('Node %d: Opportunistically accessing the channel for data transmission\n', i);
            
            % Simulate transmission with a random duration
            transmissionDuration = rand() * 5; % Random transmission duration (adjust as needed)
            
            % Accumulate latency for this node
            latencyThisStep = latencyThisStep + transmissionDuration;
            
            % Implement transmission logic here
            
            % Simulate collision with a certain probability
            if rand() < 0.2 % Adjust collision probability as needed
                fprintf('Node %d: Collision occurred\n', i);
                collisionCount = collisionCount + 1; % Increment collision count
            end
        else
            % Channel is busy, node waits
            fprintf('Node %d: Channel is busy, waiting for next opportunity\n', i);
        end
    end
    
    % Update latency array with latency for this time step
    latency(t) = latencyThisStep;
end
% Function to adjust transmission rates based on network conditions
function multiObjectiveAutoRateTransmission(nodes)
    % Simulate network conditions
    networkConditions = simulateNetworkConditions();
    
    % Iterate through each node
    for i = 1:numel(nodes)
        % Adjust transmission rate based on network conditions and objectives
        adjustTransmissionRate(nodes(i), networkConditions);
    end
end

% Function to simulate network conditions
function networkConditions = simulateNetworkConditions()
    % Simulate network conditions
    % For simplicity, let's randomly generate network conditions
    
    % Randomly generate network conditions
    networkConditions = struct(...
        'channelQuality', rand(), ...
        'trafficLoad', rand(), ...
        'otherFactors', rand() ...
    );
end

% Function to adjust transmission rate based on network conditions
function adjustTransmissionRate(node, networkConditions)
    % Adjust transmission rate based on network conditions and objectives
    % For simplicity, let's assume a linear relationship between network conditions and transmission rate
    
    % Example: Adjust transmission rate based on channel quality
    transmissionRate = node.TransmissionPower * networkConditions.channelQuality;
    
    % Update node's transmission rate
    node.TransmissionRate = transmissionRate;
    
    % Display transmission rate adjustment
    fprintf('Node %d: Adjusted transmission rate to %f\n', node.ID, transmissionRate);
end

% Function to simulate hidden node mitigation
function collisionCount = hiddenNodeMitigation(nodes)
    % Simulate hidden node mitigation
    collisionCount = 0; % Initialize collision count
    
    % Iterate through each node
    for i = 1:numel(nodes)
        % Simulate RTS/CTS exchange
        [rtsSent, ctsReceived] = simulateRtsCtsExchange(nodes(i), nodes);
        
        if rtsSent && ~ctsReceived
            % RTS sent but no CTS received, indicating hidden node
            fprintf('Node %d: Detected hidden node\n', i);
            
            % Mitigate hidden node interference using virtual carrier sensing
            mitigateHiddenNode(nodes(i), nodes);
            
            % Increment collision count
            collisionCount = collisionCount + 1;
        end
    end
end

% Function to simulate RTS/CTS exchange between sender and receiver
function [rtsSent, ctsReceived] = simulateRtsCtsExchange(sender, nodes)
    % Simulate RTS/CTS exchange between sender and receiver
    receiver = selectRandomReceiver(sender, nodes);
    
    % Simulate RTS sent by sender and CTS received by receiver
    rtsSent = true; % Assume sender always sends RTS
    ctsReceived = (rand() < 0.9); % Assume receiver has 90% chance of receiving CTS
    
    % Display RTS/CTS exchange simulation
    if rtsSent
        fprintf('Node %d: Sent RTS to Node %d\n', sender.ID, receiver.ID);
    end
    if ctsReceived
        fprintf('Node %d: Received CTS from Node %d\n', receiver.ID, sender.ID);
    end
end

% Function to select a random receiver node different from the sender
function receiver = selectRandomReceiver(sender, nodes)
    receiverIdx = randi(numel(nodes));
    while receiverIdx == sender.ID
        receiverIdx = randi(numel(nodes));
    end
    receiver = nodes(receiverIdx);
end

% Function to mitigate hidden node interference using virtual carrier sensing
function mitigateHiddenNode(node, nodes)
    % Mitigate hidden node interference using virtual carrier sensing
    % For simplicity, assume the node backs off for a random duration
    backoffDuration = rand() * 10; % Random backoff duration (adjust as needed)
    fprintf('Node %d: Backing off for %f seconds to mitigate hidden node interference\n', node.ID, backoffDuration);
    % Simulate backoff duration (optional)
    pause(backoffDuration);
end
