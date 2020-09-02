%[~,flag]=compute_distance_matrix(beads_all(index),beads_all(index_1),...
%   parameter.mindistance,3);
% [beads_all(index),beads_all(index_1)]=...
%     mark_duplicated_particle(flag,beads_all(index),beads_all(index_1));
% [beads_all(index)]=remove_duplicated_particle(beads_all(index));
% [beads_all(index_1)]=remove_duplicated_particle(beads_all(index_1));


[~,flag]=compute_distance_matrix(hydrogel_all(index),hydrogel_all(index_1),...
    parameter.mindistance,3);
[hydrogel_all(index),hydrogel_all(index_1)]=...
    mark_duplicated_hydrogel(flag,hydrogel_all(index),hydrogel_all(index_1));
[hydrogel_all(index)]=remove_duplicated_particle(hydrogel_all(index));
[hydrogel_all(index_1)]=remove_duplicated_particle(hydrogel_all(index_1));