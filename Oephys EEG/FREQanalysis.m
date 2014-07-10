
function Fa = FREQanalysis(Fs,dFs,win,chan,amp) %Input: 

%FREQanalysis downsample, filter, plot and determine PSD of data set.
%
            %FREQanalysis(Fs,dFs,win,chan,amp)
            %Fs: sampling rate (selected from oephys).
            %dFs: choose your desired downsampled frequency.
            %win: Windowing function for PSD; 1=hamming, 2=hanning, 3=bartlett.
            %chan: Channel number for analysis (1-32)
            %amp: the amplifier number (1,2) only for labeling purposes at the moment.
            %
            %PSD currently done using pwelch method.
                                       
                                        
                                        %% Load Channel Data
for ch=[chan]

load(['ch',num2str(ch),'.mat'],'data','timestamps');

%Resample Data
Dsf = Fs/dFs;

%dFs=Fs/Dsf; %Downsampled rate Ds = 500; 
Ddata=decimate(data,Dsf); %R=2; downsampled 50%
L=length(Ddata);

Dtimestamps=decimate(timestamps,60);
Lt=length(Dtimestamps);

%Notch filter for 60 Hz
dn  = fdesign.notch('N,F0,Q,Ap',2,60,10,1,dFs);
Dn = design(dn);
[nfilData] = filter(Dn,Ddata);
%Bandpass filter 0.1-100 Hz
d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',0.09,0.1,100,120,50,0.5,50,dFs);
D = design(d,'butter');
[bpfilData]=filter(D,nfilData);

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
plot(Dtimestamps,bpfilData);
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
[pxx f]= pwelch(bpfilData,window,L/2,2^nextpow2(L),dFs);

figure;
plot(f,pxx); 
title(['Electrode ',num2str(ENo)]);xlabel('Frequency (Hz)'); ylabel('Power')

end
end


    