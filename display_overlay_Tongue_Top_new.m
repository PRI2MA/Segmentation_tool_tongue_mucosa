function display_overlay_Tongue_Top_new(STRUC,ID,pmax,CT,output_dir,middleplane)

%% lateral view
CTp = permute(double(CT),[3 1 2]);
contourp = permute(bwperim(double(STRUC.TongueTop.I)),[3 1 2]);


i = middleplane;
    
J = imrotate(CTp(:,:,i),180);          
C = imrotate(contourp(:,:,i),180);
figure(35);
imshow(J,[500, 2000],'XData', [0, 120] ,'YData', [0, 100] ) 
% Make a truecolor all-green image. 
green = cat(3, zeros(size(J)),ones(size(J)), zeros(size(J))); 
hold on 
h = imshow(green,'XData', [0, 120] ,'YData', [0, 100]); 
hold off 
set(h, 'AlphaData', C)
saveas(figure(35),[output_dir,ID,'_','lateral', '.jpg']);


end

