clear all;
close all;
ipath = 'R:\20180401 b2 680 my10 647\axon_regions_complete\';
pixelSize = 167; 
dbin = 10/1000;  % micr
bb=0;
average_c=[];
txt_file='autocorrelation_amplitude.txt';
fileID = fopen([ipath txt_file],'w');
% fprintf(fileID,'%8s\t%8s\t%26s\t%8s\t%8s\r\n', 'foldername', 'filename','autocorrelation_amplitude','diameter','length');
d = dir(ipath);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'..'})) = [];
aamplitude=[];
phase=-pi/2;
filename = dir(fullfile(strcat([ipath '\'],'*.bin')));
min_channel_1_area=0;
min_channel_2_area=0;
b=1;
a1=20;
a2=20;
delete_file=[];
for ii=1:length(filename)
     xbin=0:0.01:2;
    [MList, memoryMap] = ReadMasterMoleculeList([ipath '\' filename(ii).name]);
  
    ROI=[ min(MList.yc (MList.c==2)) max(MList.yc(MList.c==2));min(MList.xc(MList.c==2)) max(MList.xc(MList.c==2))];
    renderedStack_1 = RenderMList([MList.xc(MList.c==2) MList.yc(MList.c==2)],  ...
    'gaussianWidth', 0.1, ...
    'ROI', ROI, ...
    'imageScale', a1);
%     a2=a1*length(mList.xc(mList.c==3))/length(mList.xc(mList.c==2));
    renderedStack_2 = RenderMList([MList.xc(MList.c==3) MList.yc(MList.c==3)],  ...
    'gaussianWidth', 0.1, ...
    'ROI', ROI, ...
    'imageScale', a2);
    min_length=min(size(renderedStack_1,1),size(renderedStack_2,1));
    min_width=min(size(renderedStack_1,2),size(renderedStack_2,2));
    imbw_1=imbinarize(renderedStack_1(1:min_length,1:min_width),graythresh(renderedStack_1)*b);
    imbw_2=imbinarize(renderedStack_2(1:min_length,1:min_width),graythresh(renderedStack_2)*b);
    channel_1_area=length(find(imbw_1));
    channel_2_area=length(find(imbw_2));
    if channel_1_area>min_channel_1_area&&channel_2_area>min_channel_2_area
        xcdata_1 = MList.xc(find(MList.c==2&MList.frame>000)); %pixel -> nm
        ycdata_1 = MList.yc(find(MList.c==2&MList.frame>000)); 
        x = (xcdata_1-min(xcdata_1))*pixelSize/1000;
        hist=histogram(x,xbin);
        hist_1=hist.Values;
        xcdata_2 = MList.xc(find(MList.c==3)); %pixel -> nm
        ycdata_2 = MList.yc(find(MList.c==3)); 
        x = (xcdata_2-min(xcdata_1))*pixelSize/1000;
        hist=histogram(x,xbin);
        hist_2=hist.Values;
        tlag=100;
        r1{ii} = crosscorr(hist_1,hist_2,'NumLags',tlag);
        r2{ii} = crosscorr(hist_1,hist_1,'NumLags',tlag);
        r2{ii}=r2{ii}-smooth(r2{ii},19)';
        r1{ii}=r1{ii}-smooth(r1{ii},19)';
        aamplitude(ii)=-(r1{ii}(tlag+1)+r1{ii}(tlag+20)+r1{ii}(tlag-18))/3+(r1{ii}(tlag+11)+r1{ii}(tlag-9))/2;
    else delete_file=[delete_file,ii];
    end
end

r1=mean(cell2mat(r1'),1);
r2=mean(cell2mat(r2'),1);

figure;

  xxx=-tlag*10:10:tlag*10;
%   r1=r1(end-tlag:end);
%   r2=r2(end-tlag:end);
  r2=r2-(r2(tlag+10)+r2(tlag+19))/2;
  r1=r1-(r1(tlag+10)+r1(tlag+19))/2;
  amplitude=1/r2(tlag+1);
  r1=amplitude*r1;
  r2=amplitude*r2;
  plot(xxx,r1,'k','LineWidth',1.25);hold on
  plot(xxx,r2,'r','LineWidth',1.25);hold off
  x2 = 600;
  y2 = 0.9;
%   txt2 = ['amplitude=' num2str(-(c(11)+c(30))/2+c(20))];
%   text(x2,y2,txt2)
  
  
% figHandle=figure;
% idx = find(hist{i,j}.BinEdges<900);
% plot(hist{i,j}.BinEdges(idx), acfValues{i, j}(idx),'k','LineWidth',1.25);
  xlabel('Lag (nm)','FontSize', 40)
  ylabel('A. C.','FontSize', 40);
  set(gca,'XTick',-tlag*10:500:tlag*10);
  set(gca,'YTick',-1:1:1);
  xlim([-tlag*10 tlag*10])
  ylim([-1 1.2])
  box off
  set(gca,'FontSize',40)
  set(gca,'linewidth',3)
  saveas(gcf,[ipath '\' filename(ii).name(1:end-4) '_autoCorrelation.eps'],'epsc');



