
% Make sure the Whetlab client is in the path.
addpath(genpath('..'));

% Fill in the whetlab access token.
accessToken = '';

parameters.('NumCentroids') = struct('name', 'NumCentroids', ...
                                     'type', 'integer', ...
                                     'min', 100, ...
                                     'max', 200, ... % 2500
                                     'size', 1, ...
                                     'isOutput', false);
parameters.('PatchWidth') = struct('name', 'PatchWidth', ...
                                   'type', 'integer', ...
                                   'min', 3, ...
                                   'max', 4, ... % 15
                                   'size', 1, ...
                                   'isOutput', false);
parameters.('PatchHeight') = struct('name', 'PatchHeight', ...
                                    'type', 'integer', ...
                                    'min', 3, ...
                                    'max', 4, ... % 15
                                    'size', 1, ...
                                    'isOutput', false);
parameters.('WhiteParam') = struct('name', 'WhiteParam', ...
                                   'type', 'float', ...
                                   'min', 1e-6, ...
                                   'max', 1e2, ...
                                   'size', 1, ...
                                   'isOutput', false);
parameters.('ExtraNoise') = struct('name', 'ExtraNoise', ...
                                   'type', 'float', ...
                                   'min', 1e-6, ...
                                   'max', 1e2, ...
                                   'size', 1, ...
                                   'isOutput', false);
parameters.('SVMC') = struct('name', 'SVMC', ...
                             'type', 'float', ...
                             'min', 1e-6, ...
                             'max', 1e6, ...
                             'size', 1, ...
                             'isOutput', false);
parameters.('KMeansIters') = struct('name', 'KMeansIters', ...
                             'type', 'integer', ...
                             'min', 1, ...
                             'max', 10, ... % 500
                             'size', 1, ...
                             'isOutput', false);

outcome.name = 'TestAccuracy';

name = 'Coates CIFAR-10 Pipeline I';
scientist = whetlab(name, ...
                    ['Optimizing CIFAR-10 performance with features ' ...
                    'from K-means'], ...
                    parameters, ...
                    outcome, ...
                    true,...
                    accessToken);
fprintf('Scientist created.\n');

job = [];
while isempty(job)
  try
    job = scientist.suggest();
  catch err
    err.message
    pause(5);
  end
end
fprintf('Got suggestion.\n');

failed = true;
try
  cv_acc = rand()*100;
  failed = false;
  cv_acc
catch err
  fprintf('Some serious error occurred.\n');
  err.message
end
pause(5);
fprintf('Experiment complete.\n');

% Now inform scientist about the outcome.
done = false;
while ~done
  try
    if failed
      fprintf('Reporting result as NaN.\n');
      scientist.update(job, nan);
    else
      fprintf('Reporting successful result of %f\n', cv_acc);
      scientist.update(job, cv_acc);
    end
    done = true;
    fprintf('Successful update.\n');
  catch err
    fprintf('Error in update.  Retrying...\n');
    err.message
  end
end
fprintf('Experiment complete.\n');

