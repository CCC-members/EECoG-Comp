function visualize_Head_Model_pial(source,pial,inskull,outskull,scalp,elecfids,hdr)

if nargin == 6
    hdr = '';
end
[~,~,ee] = fileparts(source);
switch lower(ee)
    case {'.srx','.mat'}
        Source = exportsurf(source,0,hdr);
        if isfield(Source,'Feat')
            plotfield(1,1,1,'none',Source.SurfData,[],Source.Feat,'hot')
        else
            plotsurf(Source.SurfData,1,1,1,'none');
        end
    case '.xyz'
        Source = ReadXYZ(source);
        hdrstruct = loadhdr(hdr);
        vx2mm = make_vx2mm(hdrstruct);
        dims = hdrstruct.dims([1 3]);
        Source = Indau2mm(Source,vx2mm,dims);
        plot3(Source(:,1),Source(:,2),Source(:,3),'*r')
end
if ~isempty(pial)
    [~,~,ee] = fileparts(pial);
    switch lower(ee)
        case {'.srx','.mat'}
            Pial = exportsurf(pial,0,hdr);
            if isfield(Pial,'Feat')
                plotfield(0,.4,1,'none',Pial.SurfData,[],Pial.Feat,'hot')
            else
                plotsurf(Pial.SurfData,0,.4,1,'none');
            end
        case '.xyz'
            Pial = readxyz(pial);
            hdrstruct = loadhdr(hdr);
            vx2mm = make_vx2mm(hdrstruct);
            dims = hdrstruct.dims([1 3]);
            Pial = indau2mm(Pial,vx2mm,dims);
            plot3(Pial(:,1),Pial(:,2),Pial(:,3),'*r')
    end
end
hold on
Inskull = exportsurf(inskull,1,hdr);
plotsurf(Inskull.SurfData,0,.4,1,'none',[0 1 2]/2/norm([0 1 2]));
% plotsurf(Inskull.SurfData,0,1,1,'none',[0 1 2]/2/norm([0 1 2]))
Outskull = exportsurf(outskull,1,hdr);
plotsurf(Outskull.SurfData,0,.25,1,'none',[1 1 1]);
Scalp = exportsurf(scalp,1,hdr);
plotsurf(Scalp.SurfData,0,.15,1,'none',[2 1 0]/norm([2 1 0]));

if ~isempty(elecfids)
    [~,~,ee] = fileparts(elecfids);
    switch lower(ee)
        case '.mat'
            ElecFids = load(deblank(elecfids));
            if isfield(ElecFids,'Fiducials')
                ElecFids.Fiducials = [ElecFids.Fiducials{2,1}; ElecFids.Fiducials{2,2}; ElecFids.Fiducials{2,3}];
            end
            if ~isfield(ElecFids,'names')
                ElecFids.names = matcell(1:size(ElecFids.electrodes,1),'');
            end
        case '.ele'
            if isempty(hdr)
                error('no VOX header file was provided');
            end
            hdrstruct = loadhdr(hdr);
            vx2mm = make_vx2mm(hdrstruct);
            dims = hdrstruct.dims([1 3]);
            Elecs = ReadELE(elecfids);
            ElecFids.electrodes = Indau2mm(double(Elecs.coords),vx2mm,dims);
            ElecFids.names = Elecs.idents';
            ElecFids.Fiducials = Indau2mm([hdrstruct.F6;hdrstruct.F3;hdrstruct.F1;hdrstruct.F2],vx2mm,dims);
        otherwise
            error('unknown format');
    end
    radius = 3; % mm
    height = 2; % mm
    propname = {5,10,'normal'};
    plotelec(Scalp.SurfData,1,ElecFids.electrodes,ElecFids.names,radius,height,[1 1 0],mean(Scalp.SurfData.vertices),propname);
    if isfield(ElecFids,'Fiducials')
        scatter3(ElecFids.Fiducials(1,1),ElecFids.Fiducials(1,2),ElecFids.Fiducials(1,3),'ob');
        scatter3(ElecFids.Fiducials(2,1),ElecFids.Fiducials(2,2),ElecFids.Fiducials(2,3),'or');
        scatter3(ElecFids.Fiducials(3:4,1),ElecFids.Fiducials(3:4,2),ElecFids.Fiducials(3:4,3),'og');
    end
end
h = gcf;
set(h,'color',[0 0 0]);
view([90 0]);
axis off;