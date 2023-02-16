unit merkez;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors, FMX.Types3D, FMX.Objects3D, FMX.Controls3D,
  FMX.Viewport3D, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects,
  FMX.Effects, FMX.MaterialSources, FireDAC.UI.Intf, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, FMX.Ani;

type
  tmovememory = record
    machse, mpos: tpoint3d;
    mlen: single;
    class function create(const aachse, apos: tpoint3d; const alen: single)
      : tmovememory; static; inline;
  end;

  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Viewport3D1: TViewport3D;
    Dummy1: TDummy;
    Dummy2: TDummy;
    Camera1: TCamera;
    Light1: TLight;
    StrokeCube1: TStrokeCube;
    Text1: TText;
    Sphere1: TSphere;
    helprotation: TDummy;
    LightMaterialSource1: TLightMaterialSource;
    LightMaterialSource2: TLightMaterialSource;
    LightMaterialSource3: TLightMaterialSource;
    LightMaterialSource4: TLightMaterialSource;
    LightMaterialSource5: TLightMaterialSource;
    LightMaterialSource6: TLightMaterialSource;
    LightMaterialSource7: TLightMaterialSource;
    LightMaterialSource8: TLightMaterialSource;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FloatAnimation1: TFloatAnimation;
    FloatAnimation2: TFloatAnimation;
    FloatAnimation3: TFloatAnimation;
    Text2: TText;
    Timer1: TTimer;
    FloatAnimation4: TFloatAnimation;
    Light2: TLight;
    Light3: TLight;
    FloatAnimation5: TFloatAnimation;
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: single);
    procedure StrokeCube1Render(Sender: TObject; Context: TContext3D);

    procedure FormCreate(Sender: TObject);
    procedure Viewport3D1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: single);
    procedure Button1Click(Sender: TObject);
    procedure FloatAnimation1Finish(Sender: TObject);
    procedure FloatAnimation2Finish(Sender: TObject);
    procedure FloatAnimation3Finish(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FloatAnimation4Finish(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    fcubemovelength: single;
    fnumberrotations: integer;
    fnumberofrotations: integer;
    procedure setcubemovelength(const Value: single);
    procedure setnumberofrotations(const Value: integer);
    { Private declarations }
  public
    { Public declarations }
    rotview, movebegin, moveend, planpoint, cubepos, globachse: tpoint3d;
    hitmove, makecube: Boolean;
    achsenr: integer;
    movmem: array of tmovememory;
    procedure hitcheckcube(const ax, ay: single);
    procedure hitmovecube(const ax, ay: single);
    procedure showinfo;
    procedure resetcube;
    procedure endmovecube(const apos, aachse: tpoint3d; alenght: single);
    procedure makemovecube;
    procedure clearcube(const acube: TDummy);
    property cubemovelength: single read fcubemovelength
      write setcubemovelength;
    property numberofrotations: integer read fnumberofrotations
      write setnumberofrotations;
      procedure revokecube;
      procedure revokecube1;
      procedure timerkapa;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
//  resetcube;

timer1.Enabled:= true;
floatanimation1.Enabled:= true;
end;

procedure TForm1.Button2Click(Sender: TObject);
//var
//q: tmovememory;
//l: integer;
//
//begin
//l:= high(movmem);
//if l = -1  then exit;
//q:= movmem[l];
//globachse:= q.machse*-1;
//cubepos:= q.mpos;
//makemovecube;
//floatanimation4.PropertyName:= 'cubemovelength';
//floatanimation4.Interpolation:= TInterpolationType.Back;
//floatanimation4.StartValue:= 0;
//floatanimation4.StopValue:= q.mlen;
//floatanimation4.Start;
//
//
//end;
begin
 revokecube;
end;

procedure TForm1.FloatAnimation4Finish(Sender: TObject);
var
q: tmovememory;
begin
q:= movmem[high(movmem)];
endmovecube(q.mpos, globachse,q.mlen);
delete(movmem,high(movmem),1);
button2.Enabled:= high(movmem)>-1;
end;

procedure TForm1.clearcube(const acube: TDummy);
var
  a: integer;
  w: troundcube;
begin
  acube.BeginUpdate;

  for a := acube.ChildrenCount - 1 downto 0 do
  begin
    w := troundcube(acube.Children[a]);
    acube.removeobject(w);
    w.Free;
  end;
  acube.ResetRotationAngle;
  acube.EndUpdate;
end;

procedure TForm1.endmovecube(const apos, aachse: tpoint3d; alenght: single);
var
  w, p: tpoint3d;
  a, b, c, d: integer;
  k, v: troundcube;
  o, h: tplane;
begin
  w.X := alenght * (180 / cpi);
  w.Y := trunc(w.X) div 90;
  w.Z := trunc(w.X) mod 90;

  if w.Z > 45 then
    w.Y := w.Y + 1;

  numberofrotations := round(w.Y);

  helprotation.RotationAngle.Point := aachse * round(w.Y) * 90;
  for a := helprotation.ChildrenCount - 1 downto 0 do
  begin
    k := troundcube(helprotation.Children[a]);
    w := helprotation.LocalToAbsolute3D(k.Position.Point);
    w := tpoint3d.create(round(w.X), round(w.Y), round(w.Z));

    for b := Dummy1.ChildrenCount - 1 downto 0 do
    begin
      v := troundcube(Dummy1.Children[b]);
      if v.Visible then
        Continue;
      if not v.Position.Point.EqualsTo(w) then
        Continue;

      for c := v.ChildrenCount - 1 downto 0 do
      begin
        o := tplane(v.Children[c]);
        o.MaterialSource := nil;

        for d := k.ChildrenCount - 1 downto 0 do
        begin
          h := tplane(k.Children[d]);
          p := helprotation.LocalToAbsolute3D(h.Position.Point).normalize;
          p := tpoint3d.create(round(p.X), round(p.Y), round(p.Z)) * 0.5;
          if not o.Position.Point.EqualsTo(p) then
            Continue;
          o.MaterialSource := h.MaterialSource;

        end;

      end;

      v.Visible := true;

    end;

  end;
 makecube:= false;
  clearcube(helprotation);
end;

procedure TForm1.FloatAnimation1Finish(Sender: TObject);
begin
  FloatAnimation1.Enabled := false;
  FloatAnimation2.Enabled := true;
end;

procedure TForm1.FloatAnimation2Finish(Sender: TObject);
begin
  FloatAnimation2.Enabled := false;
  FloatAnimation3.Enabled := true;
end;

procedure TForm1.FloatAnimation3Finish(Sender: TObject);
begin
  FloatAnimation3.Enabled := false;
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  resetcube;
  FloatAnimation5.Start;
end;

procedure TForm1.hitcheckcube(const ax, ay: single);
var
  I: Iviewport3d;
  r, d: tvector3d;
  n, f: tpoint3d;
  a: integer;
  s: single;
begin
  hitmove := false;
  I := Viewport3D1;
  I.Context.pick(ax, ay, TProjection.camera, r, d);

  if RayCastCuboidIntersect(r, d, tpoint3d.zero, 3, 3, 3, n, f) > 0 then
  begin
    planpoint := tpoint3d.zero;
    cubepos := tpoint3d.zero;
    for a := 0 to 2 do
    begin
      s := round(n.v[a] * 100) / 100;
      n.v[a] := s;
      if abs(s) = 1.5 then
      begin
        planpoint.v[a] := s;
        cubepos.v[a] := 1 * sign(s);
      end
      else
        cubepos.v[a] := round(s);

    end;

    movebegin := n;
    moveend := n;

    // for a:= 0 to dummy1.ChildrenCount -1
    // do begin
    // if troundcube(dummy1.Children[a]).Position.Point.EqualsTo(cubepos)
    // then troundcube(dummy1.Children[a]).MaterialSource:= LightMaterialSource1
    // else troundcube(dummy1.Children[a]).MaterialSource:= LightMaterialSource2;
    //
    // end;
    makecube := false;
    achsenr := -1;

    hitmove := true;
  end
  else
    rotview := Dummy2.RotationAngle.Point + tpoint3d.create(ay, -ax,
      0.5 * (ay - ax));
  showinfo;
end;

procedure TForm1.hitmovecube(const ax, ay: single);
var
  I: Iviewport3d;
  r, d: tvector3d;
  n, f: tpoint3d;
begin
  if hitmove then
  begin
    I := Viewport3D1;
    I.Context.pick(ax, ay, TProjection.camera, r, d);
    if RayCastPlaneIntersect(r, d, planpoint, planpoint.normalize, n) then
    begin
      moveend := n;
      n := movebegin - moveend;

      if n.dotproduct(n) > 0.01 then
      begin
        if achsenr = -1 then
          if ((abs(n.X) > abs(n.Y)) and (abs(n.X) > abs(n.Z))) then
            achsenr := 0
          else if ((abs(n.Y) > abs(n.X)) and (abs(n.Y) > abs(n.Z))) then
            achsenr := 1
          else if ((abs(n.Z) > abs(n.X)) and (abs(n.Z) > abs(n.Y))) then
            achsenr := 2
          else
            exit;

        f := tpoint3d.zero;
        f.v[achsenr] := 1 * sign(n.v[achsenr]);
        if abs(planpoint.X) = 1.5 then
          globachse := tpoint3d.create(0, f.Z, -f.Y) * sign(planpoint.X);
        if abs(planpoint.Y) = 1.5 then
          globachse := tpoint3d.create(-f.Z, 0, f.X) * sign(planpoint.Y);
        if abs(planpoint.Z) = 1.5 then
          globachse := tpoint3d.create(f.Y, -f.X, 0) * sign(planpoint.Z);

        makemovecube;
        cubemovelength := n.Length;
      end;

    end;

    Viewport3D1.Repaint;
  end
  else
    Dummy2.RotationAngle.Point := rotview - tpoint3d.create(ay, -ax,
      0.5 * (ay - ax));
  showinfo;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
resetcube;
end;

procedure TForm1.makemovecube;
var
  a: integer;
  w, c: troundcube;
begin
  if makecube then
    exit;
  makecube := true;
  clearcube(helprotation);

  for a := 0 to Dummy1.ChildrenCount - 1 do
  begin
    w := troundcube(Dummy1.Children[a]);
    if (globachse.X <> 0) and not(cubepos.X = w.RotationCenter.X) then
      Continue;
    if (globachse.Y <> 0) and not(cubepos.Y = w.RotationCenter.Y) then
      Continue;
    if (globachse.Z <> 0) and not(cubepos.Z = w.RotationCenter.Z) then
      Continue;
    c := troundcube(w.Clone(nil));
    c.MaterialSource := LightMaterialSource1;
    helprotation.AddObject(c);
    w.Visible := false;

  end;

end;

procedure TForm1.resetcube;

  function createplane(const mat: TLightMaterialSource;
    const p, r: tpoint3d): tplane;
  begin
    result := tplane.create(nil);
    result.MaterialSource := mat;
    result.Position.Point := p;
    result.RotationAngle.Point := r;
    result.SetSize(0.8, 0.8, 0);
    result.SubdivisionsHeight := 5;
    result.SubdivisionsWidth := 5;
    result.HitTest := false;

  end;

  procedure inittexture(const mat: TLightMaterialSource);
  var
    b: tbitmap;
    f: tbrush;
    r: trectf;
  begin
    b := tbitmap.create(100, 100);
    with b do
      if Canvas.BeginScene then
        try
          r := rectf(0, 0, width, height);
          f := tbrush.create(tbrushkind.Solid, mat.emissive);
          Canvas.Clear(0);
          Canvas.FillRect(r, 15, 15, AllCorners, 1, f);
        finally
          Canvas.EndScene;
        end;
    mat.Texture.Assign(b);
    b.Free;
  end;

var
  X, Y, Z: Integer;
  c: troundcube;
  p: tpoint3d;
begin
  clearcube(Dummy1);
  clearcube(helprotation);

  Dummy2.ResetRotationAngle;
  FloatAnimation1.Enabled := true;


  // floatanimation2.Enabled:= true;
  // floatanimation3.Enabled:= true;
  // dummy2.RotationAngle.Point:= tpoint3d.Create(41,328,328);

  fnumberofrotations := 0;
  Label1.Text := '0';

  movebegin := tpoint3d.zero;
  moveend := tpoint3d.zero;
  Button2.Enabled := false;
  movmem := nil;
  inittexture(LightMaterialSource3); // sað
  inittexture(LightMaterialSource4); // sol
  inittexture(LightMaterialSource5); // aþaðý
  inittexture(LightMaterialSource6); // yukarý
  inittexture(LightMaterialSource7); // ön
  inittexture(LightMaterialSource8); // arka

  for Z := -1 to 1 do
    for X := -1 to 1 do
      for Y := -1 to 1 do
      begin
        if (X = 0) and (Y = 0) and (Z = 0) then
          Continue;
        c := troundcube.create(nil);
        c.SetSize(0.98, 0.98, 0.98);
        c.HitTest := false;

        p := tpoint3d.create(X, Y, Z);
        c.Position.Point := p;
        c.RotationCenter.Point := p;
        c.MaterialSource := LightMaterialSource2;

        if X <> 0 then
          if X > 0 then
            c.AddObject(createplane(LightMaterialSource3, point3d(0.5, 0, 0),
              point3d(0, 270, 0))) // sað
          else
            c.AddObject(createplane(LightMaterialSource4, point3d(-0.5, 0, 0),
              point3d(0, 90, 0))); // sol

        if Y <> 0 then
          if Y > 0 then
            c.AddObject(createplane(LightMaterialSource5, point3d(0, 0.5, 0),
              point3d(90, 0, 0))) // aþaðý
          else
            c.AddObject(createplane(LightMaterialSource6, point3d(0, -0.5, 0),
              point3d(270, 0, 0))); // yukarý

        if Z <> 0 then
          if Z > 0 then
            c.AddObject(createplane(LightMaterialSource7, point3d(0, 0, 0.5),
              point3d(0, 180, 0))) // aþaðý
          else
            c.AddObject(createplane(LightMaterialSource8, point3d(0, 0, -0.5),
              point3d(0, 0, 0))); // yukarý

        Dummy1.AddObject(c);

      end;

end;

procedure TForm1.revokecube;
var
q: tmovememory;
l: integer;

begin
l:= high(movmem);
if l = -1  then exit;
q:= movmem[l];
globachse:= q.machse*-1;
cubepos:= q.mpos;
makemovecube;
floatanimation4.PropertyName:= 'cubemovelength';
floatanimation4.Interpolation:= TInterpolationType.Back;
floatanimation4.StartValue:= 0;
floatanimation4.StopValue:= q.mlen;
floatanimation4.Start;



  FloatAnimation1.Enabled := true;




  fnumberofrotations := 0;


end;

procedure TForm1.revokecube1;
begin
revokecube;
// label1.Text:= inttostr( strtoint(label1.Text) -1 );
end;

procedure TForm1.setcubemovelength(const Value: single);
begin
  fcubemovelength := Value;
  helprotation.RotationAngle.Point := globachse *
    (fcubemovelength * (180 / cpI));

end;

procedure TForm1.setnumberofrotations(const Value: integer);
begin
  fnumberofrotations := fnumberofrotations + Value;
  Label1.Text := inttostr(fnumberofrotations);
end;

procedure TForm1.showinfo;
  function point3d2str(const p: tpoint3d): string;
  begin
    result := 'x: ' + floattostrf(p.X, tfloatformat.ffFixed, 8, 2) + 'y: ' +
      floattostrf(p.Y, tfloatformat.ffFixed, 8, 2) + 'z: ' +
      floattostrf(p.Z, tfloatformat.ffFixed, 8, 2);
  end;

begin
  Text1.Text := 'planepoint: ' + point3d2str(planpoint) + linefeed +
    'planenorm: ' + point3d2str(planpoint.normalize) + linefeed + 'cubepos: ' +
    point3d2str(cubepos) + linefeed + 'globachse: ' + point3d2str(globachse) +
    linefeed + 'delta: ' + point3d2str(moveend - movebegin) + linefeed +
    'movebegin: ' + point3d2str(movebegin) + linefeed + 'moveend: ' +
    point3d2str(moveend);

end;

procedure TForm1.StrokeCube1Render(Sender: TObject; Context: TContext3D);
begin
  Context.DrawLine(movebegin, moveend, 1, talphacolors.Yellow);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
//  Text2.Text := Dummy2.RotationAngle.Point.X.ToString + linefeed +
//    Dummy2.RotationAngle.Point.Y.ToString + linefeed +
//    Dummy2.RotationAngle.Point.Z.ToString + linefeed;
 case button2.Enabled of
 true: revokecube1;
 false: timerkapa;

 end;



end;

procedure TForm1.timerkapa;
begin
timer1.Enabled:= false;
fnumberofrotations:= 0;
label1.text:= '0';
end;

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: single);
begin
  if ssleft in Shift then
    hitcheckcube(X, Y);

end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: single);
begin
  if ssleft in Shift then
    hitmovecube(X, Y);

end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: single);
begin
  if makecube then
  begin
    endmovecube(cubepos, globachse, cubemovelength);
    if cubemovelength*(180/cpi)>45 then
    begin
     SetLength(movmem,length(movmem)+1);
     movmem[high(movmem)]:= tmovememory.create(globachse,cubepos,cubemovelength);
    end;
  button2.Enabled:= high(movmem)>-1;
  end;
end;

procedure TForm1.Viewport3D1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
begin
  Camera1.Position.Z := Camera1.Position.Z - WheelDelta / 300;
end;

{ tmovememory }

class function tmovememory.create(const aachse, apos: tpoint3d;
  const alen: single): tmovememory;
begin
  result.machse := aachse;
  result.mpos := apos;
  result.mlen := alen;
end;

end.
