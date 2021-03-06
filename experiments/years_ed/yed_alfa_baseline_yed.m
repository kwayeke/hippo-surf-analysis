% Baseline experiments on rigid alineation
% Test left and right hippocampus separately
% This is new!
%% Do multivariate statistical surface analysis with freestat, akin to the paper
global MAXMEM; MAXMEM=4096;
clear all
close all
addpath('surfstat/')
addpath('utils/')
set(groot,'defaultFigureVisible','off')

%% 1. Load the data paths and covariates
meshes_l = "";
meshes_r = "";
csv = "";

avg_l_path = "";
avg_r_path = "";
avg_l_vtk = "";
avg_r_vtk = "";

exp_dir_base = "";
mkdir(exp_dir_base);

data = readtable(out_csv);
% Number of subjects
N = size(data,1);

%% Load the data
Data_loading;

%% Models
% Left hippocampus
% Create and compute model
% Both for left and right hippocampus

t_l = double(mesh_l.coord);
t_lavg = double(avg_l.coord)';
t_lavg=kron(t_lavg,ones(N,1));
t_lavg=reshape(t_lavg,N,2511,3);
t_l = t_l - t_lavg;

t_r = double(mesh_r.coord);
t_ravg = double(avg_r.coord)';
t_ravg=kron(t_ravg,ones(N,1));
t_ravg=reshape(t_ravg,N,2636,3);
t_r = t_r - t_ravg;

model_l = 1 + Age + Gender + Apoe + Yed;
model_r = 1 + Age +  Gender + Apoe + Yed;

slm_l = SurfStatLinMod(t_l, model_l, avg_l);
slm_r = SurfStatLinMod(t_r, model_r, avg_r);

% ADDITIVE
model_r_add = 1 + Age + Gender + Apoe_int + Yed;
model_l_add = 1 + Age + Gender + Apoe_int + Yed;

slm_l_add = SurfStatLinMod(t_l, model_l_add, avg_l);
slm_r_add = SurfStatLinMod(t_r, model_r_add, avg_r);


% Corr is a matrix with the indexes of the design matrix that need to be 
% corrected for the age/apoe interaction figure
% In this case, it represents the intercept, gender (M and F) and volume.
% if it contains nothing, then it interprets that there is no interaction
% and do not compute the figure (see utils/save_peaks_figure.m)
corr = [];


%% Save uncorrected tests to disk
% Save, for each contrast:
% The uncorrected image
% The corrected image
% the .vtk with the uncorrected maps on it, somehow (call to python?)
% List of contrasts

contrast_list = {-age, age,...% volume_l, -volume_l,...
                 Gender.M-Gender.F, Gender.F-Gender.M, yed, -yed,...
                 Apoe.HE-Apoe.NC, Apoe.NC-Apoe.HE,...
                 Apoe.HO-Apoe.NC, Apoe.NC-Apoe.HO,...
                 Apoe.HE-Apoe.HO, Apoe.HO-Apoe.HE,...
                 (0.5*Apoe.HE+0.5*Apoe.NC) - Apoe.HO,...
                 Apoe.HO - (0.5*Apoe.HE+0.5*Apoe.NC),...
                 (0.5*Apoe.HE+0.5*Apoe.HO) - Apoe.NC,...
                 Apoe.NC - (0.5*Apoe.HE+0.5*Apoe.HO),...
                 };

% List of files to save
%
save_file = {'-age', '+age',...% 'volume', '-volume'...
             '+male_-female', '+female_-male','yed', '-yed',...
             '+HE_-NC', '+NC_-HE', '+HO_-NC', '+NC_-HO', '+HO_-HE',...
             '+HE_-HO', 'HE+NC-HO', '-HE-NC+HO', 'HE+HO-NC', '-HE-HO+NC'};

 % ADDITIVE MODEL
contrast_list_add = {apoe_int, -apoe_int};
save_file_add = {'NC_HE_HO', '-NC_HE_HO'};

%% Left

% output_dir
exp_dir = strcat(exp_dir_base, 'lefthippo/');
mkdir(exp_dir);

save_exp_to_disk(contrast_list,save_file,exp_dir,avg_l,slm_l,avg_l_vtk, t_l, age, apoe, corr)

% ADDITIVE MODEL
save_exp_to_disk(contrast_list_add,save_file_add,exp_dir,avg_l,slm_l_add,avg_l_vtk, t_l, age, apoe, corr)

%% Right

% output_dir
exp_dir = strcat(exp_dir_base, 'righthippo/');
mkdir(exp_dir);

contrast_list = {-age, age,...% volume_r, -volume_r,...
                 Gender.M-Gender.F, Gender.F-Gender.M, yed, -yed,...
                 Apoe.HE-Apoe.NC, Apoe.NC-Apoe.HE,...
                 Apoe.HO-Apoe.NC, Apoe.NC-Apoe.HO,...
                 Apoe.HE-Apoe.HO, Apoe.HO-Apoe.HE,...
                 (0.5*Apoe.HE+0.5*Apoe.NC) - Apoe.HO,...
                 Apoe.HO - (0.5*Apoe.HE+0.5*Apoe.NC),...
                 (0.5*Apoe.HE+0.5*Apoe.HO) - Apoe.NC,...
                 Apoe.NC - (0.5*Apoe.HE+0.5*Apoe.HO),...
                 };


save_exp_to_disk(contrast_list,save_file,exp_dir,avg_r,slm_r,avg_r_vtk, t_r, age, apoe, corr)

% ADDITIVE MODEL
save_exp_to_disk(contrast_list_add,save_file_add,exp_dir,avg_r,slm_r_add,avg_r_vtk, t_r, age, apoe, corr)
