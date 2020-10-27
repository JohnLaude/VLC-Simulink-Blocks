function new_block(block)
% Author: John Carlo Laude
% Date: 09/24/2020
% This is a block made for VLC. It is made from a Level-2 M-file
% S-function that allows the user to change the paramaters to simulate
% the use of VLC. It is a dynamic block that is basically multiplier that
% will be used in an OWC channel
setup(block);

%endfunction

%% Function: setup ===================================================
function setup(block)

% % Simulink passes an instance of the Simulink.MSFcnRunTimeBlock class 
% to the setup method in the input argument "block". This is known as 
% the S-function block's run-time object.

% Register original number of input ports based on the S-function
% parameter values

try % Wrap in a try/catch, in case no S-function parameters are entered
    lowMode    = block.DialogPrm(1).Data;
    upMode     = block.DialogPrm(3).Data;
    numInPorts = 1 + isequal(lowMode,3) + isequal(upMode,3);
catch
    numInPorts=1;
end
block.NumInputPorts = numInPorts;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';

% Override output port properties
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% Register parameters. In order:
% -- If the upper bound is off (1) or on and set via a block parameter (2)
%    or input signal (3)
% -- The upper limit value. Should be empty if the upper limit is off or
%    set via an input signal
% -- If the lower bound is off (1) or on and set via a block parameter (2)
%    or input signal (3)
% -- The lower limit value. Should be empty if the lower limit is off or
%    set via an input signal
block.NumDialogPrms     = 4;
block.DialogPrmsTunable = {'Nontunable','Tunable','Nontunable', ...
    'Tunable'};

% Register continuous sample times [0 offset]
block.SampleTimes = [0 0];

%% -----------------------------------------------------------------
%% Options
%% -----------------------------------------------------------------
% Specify if Accelerator should use TLC or call back into
% M-file
block.SetAccelRunOnTLC(false);

%% -----------------------------------------------------------------
%% Register methods called during update diagram/compilation
%% -----------------------------------------------------------------

block.RegBlockMethod('CheckParameters',      @CheckPrms);
block.RegBlockMethod('ProcessParameters',    @ProcessPrms);
block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
block.RegBlockMethod('Outputs',              @Outputs);
block.RegBlockMethod('Terminate',            @Terminate);
%end setup function

%% Function: CheckPrms ===================================================
function CheckPrms(block)

tx_angle = block.DialogPrm(1).Data;
height_dif  = block.DialogPrm(2).Data;
sig_str  = block.DialogPrm(3).Data;
visibiility   = block.DialogPrm(4).Data;

% The first and third dialog parameters must have values of 1-3
if ~any((0< tx_angle)^(tx_angle < 90));
    error('The first dialog parameter must be between 0 and 90');
end

if ~any(height_dif >= 0);
    error('The first dialog parameter must be a positive value');
end

if ~any(sig_str >= 0);
    error('The first dialog parameter must be a positive value');
end

if ~any((visibiility > 0)^(visibiility <= 1));
    error('The first dialog parameter must be a positive value');
end



%end CheckPrms function

%% Function: ProcessPrms ===================================================
function ProcessPrms(block)

%% Update run time parameters
block.AutoUpdateRuntimePrms;

%end ProcessPrms function

%% Function: DoPostPropSetup ===================================================
function DoPostPropSetup(block)

%% Register all tunable parameters as runtime parameters.
block.AutoRegRuntimePrms;

%end DoPostPropSetup function

%% Function: Outputs ===================================================
function Outputs(block)
% Four Parameters
tx_angle = block.DialogPrm(1).Data;
height_dif  = block.DialogPrm(2).Data;
sig_str  = block.DialogPrm(3).Data;
visibility   = block.DialogPrm(4).Data; % Scalar
% Input Signals
input_sig = block.InputPort(1).Data;

sigVal = (sig_str/(cos(tx_angle)*height_dif))*visibility*input_sig;

block.OutputPort(1).Data = sigVal;

%end Outputs function

%% Function: Terminate ===================================================
function Terminate(block)
%end Terminate function