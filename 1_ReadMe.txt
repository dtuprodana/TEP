
Copyright © 2021 Technical University of Denmark
 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 

A tool for big data generation for time dependent processes:
The Tennessee Eastman process for generating large quantities of process data.

by Andersen et al. (2021)


This folder contains the GUI as well as pre-compiled executables to run the model on Windows and Mac Computers.

The GUI is started by executing "TEP_GUI_DATAGEN_vxxx.m" from the Matlab prompt. 
Simulink runs in the background and remains invisible.

One of the two control structures, either the one of Ricker or a simple one for illustrative purposes, may be chosen 
by commenting / uncommenting one of the two lines shown here in "TEP_GUI_DATAGEN_vxxx.m"

  % Simulink object variables                 % -- Choose model here! --
  SYSTEMOBJ = 'MultiLoop_mode1';              %     (1) Ricker          
  %SYSTEMOBJ = 'tesysbasecontrol_2';          %     (2) Simple

A detailed description of the use of the GUI is given in "An easy to use GUI for simulating Big Data using Tennessee Eastman Process" by Andersen et al. (2021)


Third party components are from

- N.L. Ricker, Optimal steady-state operation of the Tennessee Eastman challenge process, Comput. Chem. Eng. 19 (1995) 949–959. https://doi.org/10.1016/0098-1354(94)00043-N.


- A. Bathelt, N. L. Ricker, and M. Jelali, “Revision of the Tennessee Eastman Process Model,” IFACPapersOnLine, vol. 48, no. 8, pp. 309–314, Jan. 2015, doi: 10.1016/J.IFACOL.2015.08.199.


- Houtzager, I., Available online: 2019. Simulink Block for Real Time Execution. https://de.mathworks.com/matlabcentral/fileexchange/30953-simulink-block-for-real-time-execution.
Copyright (c) 2015, Ivo Houtzager
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 


