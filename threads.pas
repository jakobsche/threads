{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit threads;

{$warn 5023 off : no warning about unused units}
interface

uses
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('threads', @Register);
end.
