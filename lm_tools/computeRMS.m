function [RMSx, RMSy] = computeRMS(xdata,ydata,screentodeg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROY HESSELS - 2014
% ET QUALITY CONTROL EUAIMS / IMI
% royhessels@gmail.com
%
% Calculates RMS noise in horizontal and vertical coordinates
% Inputs:
% xdata = horizontal coordinates for one data file
% ydata = vertical coordinates for one data file
% screentodeg = factor for turning position between 0&1 to degrees visual
% angle
%
% NOTES:
%
% If calculating noise for both eyes, call function twice (once for LE,
% once for RE)
% Does not account for periods of data loss. If data loss is not accounted
% for, RMS values for data with data loss will be overestimated. Another
% option is to feed only the coordinates with xdata(eyefound == 1) and
% ydata(eyefound==1).
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute difference between samples, and square
dx = (xdata(1:end-1) - xdata(2:length(xdata))).^2;
dy = (ydata(1:end-1) - ydata(2:length(ydata))).^2;

% calculate RMS
RMSx = sqrt(nansum(dx)/length(dx));
RMSy = sqrt(nansum(dy)/length(dy));

% convert from pixels to degrees visual angle
RMSx = RMSx * screentodeg;
RMSy = RMSy * screentodeg;

return