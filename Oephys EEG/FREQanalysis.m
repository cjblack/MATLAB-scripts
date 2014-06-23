
function Fa = FREQanalysis(Fs,win,chan,amp) %Input: 

%FREQanalysis downsample, filter, plot and determine PSD of data set.
%
            %FREQanalysis(Fs,win,chan,amp)
            %Fs: sampling rate (selected from oephys)
            %win: Windowing function for PSD; 1=hamming, 2=hanning, 3=bartlett.
            %chan: Channel number for analysis (1-32)
            %amp: the amplifier number (1,2) only for labeling purposes at the moment.
            %
            %PSD currently done using pwelch method.
                                       
                                        
                                        %% Load Channel Data
for ch=[chan]

load(['ch',num2str(ch),'.mat'],'data','timestamps');

%Resample Data

dFs=Fs/2; %Downsampled rate
Ddata=decimate(data,2); %R=2; downsampled 50%
L=length(Ddata);

Dtimestamps=decimate(timestamps,2);
Lt=length(Dtimestamps);

%Bandpass filter 0.1-100 Hz
d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',0.09,0.1,100,120,50,0.5,50,1e3);
D = design(d,'butter');
[filData]=filter(D,Ddata);

%Ampflier Selection; applies to 64 channel BrainCap MR
chanMap=[8,9,10,6,7,11,12,4,5,13,14,2,3,15,16,32,1,17,18,31,30,19,20,29,28,21,22,27,25,23,24,26];
if amp==1
    ENo=find(chanMap==chan);
end

if amp==2
    ENo=find(chanMap==chan)+32;
end

%Plot filtered data
figure;
plot(Dtimestamps,filData);
title(['Electrode ',num2str(ENo)]);xlabel('Time (Seconds)');ylabel('Voltage (uV)')

%Window selection - add more...
if win==1
    window=hamming(L);
end

if win==2
    window=hanning(L);
end

if win==3
    window=bartlett(L);
end

%PSD using pwelch method...include others in future
[pxx f]= pwelch(filData,window,L/2,2^nextpow2(L),dFs);

figure;
plot(f,pxx); 
title(['Electrode ',num2str(ENo)]);xlabel('Frequency (Hz)'); ylabel('Power')

end
end


    