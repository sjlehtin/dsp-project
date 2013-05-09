function lines = speksitIIR(Wp, Ws, Rp, Rs, type, Fs)
% SPEKSITIIR piirtää aktiiviseen ikkunaan annetut IIR-suotimen speksit.
% SPEKSITIIR draws the specifications in the axis
%   [lines] = speksitIIR(Wp, Ws, Rp, Rs, type, [Fs]);
%
%   Soveltuu vain LP/HP/BP/BS-suotimille, IIR-suunnittelun
%   spekseillä. Maksimi tulee olla skaalattuna 0 dB:en. /
%   Only for LP/HP/BP/BS-filters using IIR filter specifications.
%   The maximum has to be scaled to 0 dB.
%
%   The input variables Wp, Ws, Rp, Rs as explained
%   in "help buttord", filter types as in "help butter"
%
%   Wp     päästökaistan rajataajuus / cut-off for passband
%   Ws     estokaistan rajataajuus / cut-off for stopband
%   Rp     päästön rippeli / maximum ripple in passband
%   Rs     eston minimivaimennus / minimum attenuation in stopband
%   type   LP: '' (default), HP: 'high', BP: '', BS: 'stop'
%   Fs     Näytteenottotaajuus / Sampling frequency, default==2
%
%   lines  kahvat viivoihin / handles to line objects
%
% EXAMPLE
%   Wp  = 0.3;  Ws = 0.4;  Rp = 3;  Rs = 20;  fT = 22050;
%   [N, Wn] = ellipord(Wp, Ws, Rp, Rs);
%   [B, A ] = ellip(N, Rp, Rs, Wn);
%   freqz(B, A, 512, fT);
%   speksitIIR(Wp, Ws, Rp, Rs, '', fT);


% Jukka Parviainen, parvi@hut.fi, 2011 / 7.4.2008 / 20.10.2004

if nargin<4
  error('Liian vähän argumentteja / Too few arguments, "help speksit"');
end;
if nargin==4
   Fs   = 2;
   type = '';    % type = LP / BP
end;
if nargin==5
   if isnumeric(type)
      % type = LP / BP
      Fs   = type;
      type = '';
   elseif ischar(type)
      Fs = 2;
   end;
end;
if nargin>6
  error('Liian paljon argumentteja / Too many arguments, "help speksit"');
end;

%XL = get(gca,'XLim');
%YL = get(gca,'YLim');

if ((strcmp(type,'high')==1) | (strcmp(type,'stop')==1) | (strcmp(type,'')==1))
   % OK
else
   error('Väärä "type" / wrong "type", "help speksit"');
end;


if (length(Wp)==2 & length(Ws)==2)
   if isempty(type)
      type = 'pass';  % BANDpass
   end;
elseif (length(Wp)==1 & length(Ws)==1)
   if isempty(type)
      type = 'low';
   end;
else
   error('Wp ja Ws eivät saman kokoiset / Wp and Ws not of same size, "help speksit"');   
end;

if (any([Wp Ws]>=1) | any([Wp Ws]<=0))
   error('Wp ja Ws pitää olla välillä (0,1) / Wp and Ws in range (0,1), "help speksit"');
end;

fs2 = Fs/2;
fpa = Wp*fs2;
fst = Ws*fs2;
plustext = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (plustext)
  hcurve = get(gca,'Children');
  if length(hcurve)==1
     % Oletetaan, että pohjalla on vain tuo käyrä freqz(B,A):sta
     XD = get(hcurve,'XData');
     YD = get(hcurve,'YData');
     set(hcurve,'Visible','off');
  end;
end;

% Vaakaviivat päästökaistoille
% Horizontal lines to passbands
if (strcmp(type,'low')==1)
   tmpP(1) = line([0 fpa(1)], [0 0]);
   tmpP(2) = line([0 fpa(1)], [-Rp -Rp]);
   pts = fpa(1)/2;
elseif (strcmp(type,'high')==1)
   tmpP(1) = line([fpa(1) fs2], [0 0]);
   tmpP(2) = line([fpa(1) fs2], [-Rp -Rp]);
   pts = fpa(1) + (fs2-fpa(1))/2;
elseif (strcmp(type,'pass')==1)
   tmpP(1) = line([fpa(1) fpa(2)], [0 0]);
   tmpP(2) = line([fpa(1) fpa(2)], [-Rp -Rp]);
   pts = fpa(1) + (fpa(2)-fpa(1))/2;
elseif (strcmp(type,'stop')==1)
   tmpP(1) = line([0 fpa(1)], [0 0]);
   tmpP(2) = line([0 fpa(1)], [-Rp -Rp]);
   tmpP(3) = line([fpa(2) fs2], [0 0]);
   tmpP(4) = line([fpa(2) fs2], [-Rp -Rp]);   
   pts = [fpa(1)/2  fpa(2)+(fs2-fpa(2))/2];
else
   error('foo');
end;
if (plustext)
%   pts
   for k=1:length(pts)
     t(k) = text(pts(k), -Rp-(0.3*(Rs-Rp)), 'Passband');
   end;
   set(t, 'FontSize', 12, 'HorizontalAlignment', 'center');
end;


% Vaakaviivat estokaistoille
% Horizontal lines to stopbands
if (strcmp(type,'low')==1)
   tmpS(1) = line([fst(1) fs2], [-Rs -Rs]);
   sts = fst(1) + (fs2-fst(1))/2;
elseif (strcmp(type,'high')==1)
   tmpS(1) = line([0 fst(1)], [-Rs -Rs]);
   sts = fst(1)/2;
elseif (strcmp(type,'pass')==1)
   tmpS(1) = line([0 fst(1)], [-Rs -Rs]);
   tmpS(2) = line([fst(2) fs2], [-Rs -Rs]);
   sts = [fst(1)/2   (fst(2)+(fs2-fst(2))/2)];
elseif (strcmp(type,'stop')==1)
   tmpS(1) = line([fst(1) fst(2)], [-Rs -Rs]);
   sts = fst(1) + (fst(2)-fst(1))/2;
else
   error('foo');
end;
if (plustext)
%   sts
   for k=1:length(sts)
     t(k) = text(sts(k), -0.7*Rs, 'Stopband');
   end;
   set(t, 'FontSize', 12, 'HorizontalAlignment', 'center');
end;


% Pystyviivat päästökaistoille
% Vertical lines to passbands
if (strcmp(type,'low')==1)
   tmpV(1) = line([fpa(1) fpa(1)], [0 200]);
   tmpV(2) = line([fpa(1) fpa(1)], [-Rp -400]);
elseif (strcmp(type,'high')==1)
   tmpV(1) = line([fpa(1) fpa(1)], [0 200]);
   tmpV(2) = line([fpa(1) fpa(1)], [-Rp -400]);
elseif (strcmp(type,'pass')==1)
   tmpV(1) = line([fpa(1) fpa(1)], [0 200]);
   tmpV(2) = line([fpa(1) fpa(1)], [-Rp -400]);
   tmpV(3) = line([fpa(2) fpa(2)], [0 200]);
   tmpV(4) = line([fpa(2) fpa(2)], [-Rp -400]);
elseif (strcmp(type,'stop')==1)
   tmpV(1) = line([fpa(1) fpa(1)], [0 200]);
   tmpV(2) = line([fpa(1) fpa(1)], [-Rp -400]);
   tmpV(3) = line([fpa(2) fpa(2)], [0 200]);
   tmpV(4) = line([fpa(2) fpa(2)], [-Rp -400]);
else
   error('foo');
end;



% Pystyviivat estokaistoille
% Vertical lines to stopbands
if (strcmp(type,'low')==1)
   tmpW(1) = line([fst(1) fst(1)], [-Rs 200]);
elseif (strcmp(type,'high')==1)
   tmpW(1) = line([fst(1) fst(1)], [-Rs 200]);
elseif (strcmp(type,'pass')==1)
   tmpW(1) = line([fst(1) fst(1)], [-Rs 200]);
   tmpW(2) = line([fst(2) fst(2)], [-Rs 200]);
elseif (strcmp(type,'stop')==1)
   tmpW(1) = line([fst(1) fst(1)], [-Rs 200]);
   tmpW(2) = line([fst(2) fst(2)], [-Rs 200]);
else
   error('foo');
end;


set(tmpP,'Color',[0 1 0],'LineWidth',2);
set(tmpS,'Color',[1 0 0],'LineWidth',2);
set(tmpV,'Color',[0 1 0],'LineWidth',2);
set(tmpW,'Color',[1 0 0],'LineWidth',2);

lines.horiz1 = tmpP;
lines.horiz2 = tmpS;
lines.verti1 = tmpV;
lines.verti2 = tmpW;
lines.all    = [tmpP tmpS tmpV tmpW];

if (plustext)
  if length(hcurve)==1
     % Oletettiin, että pohjalla on vain tuo käyrä freqz(B,A):sta
     % Halutaan saada käyrä päälle!
     hold on;
     plot(XD, YD);
     hold off;
  end;
end;

axis([0 fs2 -1.5*Rs 0.2*Rs]);

%ylabel('dB');

