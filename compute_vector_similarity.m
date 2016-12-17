function [similarity] = compute_vector_similarity(vectorA, vectorB)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    vectorBSizeAdjusted = vectorB(1 : length(vectorA), 1);

    % NOTE: we need to transpose the vectors!

    % Failed attempts
%     similarity = pdist([vectorA'; vectorBSizeAdjusted'], 'cosine');
%     similarity = corrcoef([vectorA'; vectorBSizeAdjusted']);
     similarity = pdist2(vectorA', vectorBSizeAdjusted', 'hamming');
     similarity = pdist2(vectorA', vectorBSizeAdjusted', 'cosine');
     
     similarity = sum(vectorA' == vectorBSizeAdjusted') / numel(vectorA')
end
    