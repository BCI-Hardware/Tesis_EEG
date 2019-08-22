%**************************************************************************
%                            TESIS DE GRADO
%                               EEG v1.0
%                   Instituto de Ingenieria Biomédica
%           Facultad de Ingenieria, Universidad de Buenos Aires
%
%                           Florencia Grosso
%                           Tutor: Sergio Lew
%
%  Code description:
%  This code takes input data and removes outliers. The outliers to remove
%  are taken from .mat files, one per channel:
%
%    CH1: /data/+_ch1_outliers.mat
%    CH2: /data/+_ch2_outliers.mat
%
%  each of these workspaces contain a variable 'outliers' which is an MxN
%  matrix. M is the number of outliers to remove. Each row has the 
%  following data:
%
%  [x1 x2 y1 y2]
%
%  With:
%  - (x1, y1): point where the outlier begins.
%  - (x2, y2): point where the outlier ends.
%
%  The script removes the data between those points and then links them
%  through simple interpolation.
%  It returns a matrix with the filtered input data (no outliers).
%**************************************************************************

function channel = fill_outliers(channel)
%% Channel 1   
   outliers_data = load('data/09_09_2018_19_30_28_ch1_outliers.mat');
   outliers = outliers_data.outliers;
   
   % outliers is an MxN matrix. M is the number of outliers to remove. Each
   % row has the following data:

  
    for j=1:size(outliers,1)
        coefficients = polyfit([outliers(j,1), outliers(j,2)], [outliers(j,3), outliers(j,4)], 1);
        a = coefficients (1);
        b = coefficients (2);
        
        for n=round(outliers(j,1)*250):1:round(outliers(j,2)*250)
            channel(n, 1) = a * (n/250) + b;
        end
    end
%% Channel 2
   outliers_data = load('data/09_09_2018_19_30_28_ch2_outliers.mat');
   outliers = outliers_data.outliers;
   
   outliers = [[6, 6.496, 129.2, 84.15]; outliers];
    
    for j=1:size(outliers,1)
        coefficients = polyfit([outliers(j,1), outliers(j,2)], [outliers(j,3), outliers(j,4)], 1);
        a = coefficients (1);
        b = coefficients (2);
        
        for n=round(outliers(j,1)*250):1:round(outliers(j,2)*250)
            channel(n, 2) = a * (n/250) + b;
        end
    end
   

end
