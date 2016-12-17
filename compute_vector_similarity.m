function [similarity] = compute_vector_similarity(vectorA, vectorB)
    % UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    vectorBSizeAdjusted = vectorB(1 : length(vectorA), 1);

    % NOTE: we need to transpose the vectors!

    % Failed attempts
%     similarity = pdist([vectorA'; vectorBSizeAdjusted'], 'cosine');
%     similarity = corrcoef([vectorA'; vectorBSizeAdjusted']);

    % Cosine and hamming distances
	similarity = 1 - pdist2(vectorA', vectorBSizeAdjusted', 'hamming');
    fprintf('Hamming similarity between specified vectors: %d \n', ...
        similarity);

	similarity = 1 - pdist2(vectorA', vectorBSizeAdjusted', 'cosine');
    fprintf('Cosine similarity between specified vectors: %d \n', ...
        similarity);

	% Naive approach from: 
    % https://se.mathworks.com/matlabcentral/newsreader/view_thread/163277
	similarity = sum(vectorA' == vectorBSizeAdjusted') / numel(vectorA');
    fprintf('Naive similarity between specified vectors: %d \n', ...
        similarity);
end
    