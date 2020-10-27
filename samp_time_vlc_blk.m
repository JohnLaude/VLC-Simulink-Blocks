function excel_param_vlc_blk(block)
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

block.NumInputPorts = 5;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';

% Override input port properties Time
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';

% Override input port properties
block.InputPort(3).DatatypeID  = 0;  % double
block.InputPort(3).Complexity  = 'Real';

% Override input port properties Time
block.InputPort(4).DatatypeID  = 0;  % double
block.InputPort(4).Complexity  = 'Real';

% Override input port properties Time
block.InputPort(5).DatatypeID  = 0;  % double
block.InputPort(5).Complexity  = 'Real';

% Output Block
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';


% Register parameters. In order:
% -- If the upper bound is off (1) or on and set via a block parameter (2)
%    or input signal (3)
% -- The upper limit value. Should be empty if the upper limit is off or
%    set via an input signal
% -- If the lower bound is off (1) or on and set via a block parameter (2)
%    or input signal (3)
% -- The lower limit value. Should be empty if the lower limit is off or
%    set via an input signal
block.NumDialogPrms     = 3;
block.DialogPrmsTunable = {'Tunable','Tunable','Tunable'};

% Register continuous sample times [0 offset]
block.SampleTimes = [0.2 0];

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

%end CheckPrms function

%% Function: ProcessPrms ===================================================
function ProcessPrms(block)

%% Update run time parameters
block.AutoUpdateRuntimePrms;
samp_time = block.InputPort(5).Data
block.SampleTimes = [samp_time 0];
%end ProcessPrms function

%% Function: DoPostPropSetup ===================================================
function DoPostPropSetup(block)

%% Register all tunable parameters as runtime parameters.
block.AutoRegRuntimePrms;

%end DoPostPropSetup function

%% Function: Outputs ===================================================
function Outputs(block)
% Four Parameters
Gain_Received = block.InputPort(2).Data;
Gain_Transmission  = block.InputPort(3).Data;
distance  = block.InputPort(4).Data;
% Input Signals
input_sig = block.InputPort(1).Data;
% Process
sigVal = input_sig*((Gain_Received*Gain_Transmission)/(distance^2));

block.OutputPort(1).Data = sigVal;
%end Outputs function

%% Function: Terminate ===================================================
function Terminate(block)
%end Terminate function