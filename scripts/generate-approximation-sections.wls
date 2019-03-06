#!/usr/bin/env wolframscript
(* ::Package:: *)

Print["generate-approximation-sections.wls: Started."];


directory=Directory[];


(*LaunchKernels[];*)


ClearAll[createApproximationParagraph];
createApproximationParagraph[s_String,relative_/;BooleanQ@relative,sine_/;BooleanQ@sine]:=With[{outPrecision=36,inPrecision=96},
Block[{$MinPrecision=outPrecision},With[{ai=SetPrecision[ToExpression[StringReplace["{"<>s<>"}","e"->"*^"]],inPrecision]},
With[{ph2pi=SetPrecision[HornerForm[Sum[ai[[i]] SetPrecision[(2 Pi)^(i 2-If[sine,1,2]),inPrecision] #^(i 2-If[sine,1,2]),{i,Length[ai]}]],outPrecision]},With[{pcf=StringReplace[ToString[CForm[HornerForm[Sum[SetPrecision[ai[[i]],outPrecision] x^(i 2-If[sine,1,2]),{i,Length[ai]}]]]],{"Power(x,2)"->"x2", "x"->"x1"}],pcf2pi=StringReplace[ToString[CForm[SetPrecision[HornerForm[Sum[ai[[i]] SetPrecision[(2 Pi)^(i 2-If[sine,1,2]),inPrecision] x^(i 2-If[sine,1,2]),{i,Length[ai]}]],outPrecision]]],{"Power(x,2)"->"x2", "x"->"x1"}],
coeffSymbolString=If[sine,"s","c"]<>If[relative,"r","a"]<>TextString[Length[ai] 2 - If[sine,1,2]],
aiOut=SetPrecision[ai,outPrecision],
errRel=If[And[Not[sine],Not[relative],Function[ph2pi][1/4]!=0],Infinity,SetPrecision[Quiet[NMaxValue[{Abs[1-Function[ph2pi][x]/If[sine,Sin,Cos][x 2 Pi]],x>0+10^(-outPrecision),x<1/4-10^(-outPrecision)},x,PrecisionGoal->outPrecision,WorkingPrecision->outPrecision,MaxIterations->1000],{NMaxValue::cvdiv}],outPrecision]],
errAbs=SetPrecision[NMaxValue[{Abs[Function[ph2pi][x]-If[sine,Sin,Cos][x 2 Pi]],x>0+10^(-outPrecision),x<1/4-10^(-outPrecision)},x,PrecisionGoal->outPrecision,WorkingPrecision->outPrecision,MaxIterations->1000],outPrecision]},
With[{filePlot="error-plot-"<>coeffSymbolString<>".svg",fileText="section-"<>coeffSymbolString<>".adoc"},With[{plots=With[{sz=400},{Plot[Function[ph2pi][x]-If[sine,Sin,Cos][2 Pi x],{x,0,1/4},ImageSize->{sz,sz/GoldenRatio},PlotLabel->"Absolute Error",WorkingPrecision->outPrecision,PlotRange->{-errAbs,errAbs} 1.1,Frame->True,GridLines->Automatic,PerformanceGoal->"Quality",PlotPoints->2^10],Plot[Function[ph2pi][x]/If[sine,Sin,Cos][2 Pi x]-1,{x,0,1/4},ImageSize->{sz,sz/GoldenRatio},PlotLabel->"Relative Error",WorkingPrecision->outPrecision,PlotRange->If[errRel==Infinity,Automatic,{-errRel,errRel} 1.1],Frame->True,GridLines->Automatic,PerformanceGoal->"Quality",PlotPoints->2^10]}],text="=== "<>If[sine,"Sin, ","Cos, "]<>If[relative,"rel.","abs."]<>" error minimized, degree " <> TextString[Length[ai] 2 - If[sine,1,2]]<>"\n\n"<>"Maximum relative error: "<>If[errRel==Infinity,"\[Infinity]",ToString[CForm[errRel]]]<>" +\nMaximum absolute error: "<>ToString[CForm[errAbs]]<>"\n\n"<>"[#error-plot-"<>coeffSymbolString<>"]\nimage::"<>filePlot<>"[error-plot-"<>coeffSymbolString<>",width=100%,pdfwidth=100%,scaledwidth=100%]\n\n"<>"C-style Horner evaluation for sin(2\[Pi]x) approximation"<>If[Length[ai]>1," (set "<>If[sine,"`x1 = x` and ",""]<>"`x2 = x * x` first)",If[sine," (set `x1 = x` first)",""]]<>":"<>"\n\n"<>"[source,C]\n"<>"----\n"<>pcf2pi<>"\n----\n\n"<>"C-style Horner evaluation for sin(x) approximation"<>If[Length[ai]>1," (set "<>If[sine,"`x1 = x` and ",""]<>"`x2 = x * x` first)",If[sine," (set `x1 = x` first)",""]]<>":"<>"\n\n"<>"[source,C]\n"<>"----\n"<>pcf<>"\n----\n\n"<>"WL-style coefficient list:"<>"\n\n"<>"[source,Wolfram Language]\n"<>"----\n"<>ToString[InputForm[aiOut]]<>"\n----\n\n"},{{fileText,filePlot},text,GraphicsRow[plots]}]]]]]]];


With[{outfilesPath=FileNameJoin[{directory,"outfiles"}],maxDegree=16,includesPath=FileNameJoin[{directory,"includes"}],imagesPath=FileNameJoin[{directory,"images"}]},With[{strings=Table[With[{file=FileNameJoin[{outfilesPath,k<>"-"<>IntegerString[i,10,2]<>"-"<>j<>".txt"}]},StringSplit[Import[file,"String"],{"[","]"}][[2]]],{k,{"sine","cosine"}},{j,{"relative","absolute"}},{i,0,maxDegree}]},With[{p=(*Parallel*)Table[createApproximationParagraph[strings[[k,j,i]],j==1,k==1],{k,2},{j,2},{i,maxDegree+1}]},With[{includeStrings=Table[Export[FileNameJoin[{includesPath,p[[k,j,i,1,1]]}],p[[k,j,i,2]],"Text"];Export[FileNameJoin[{imagesPath,p[[k,j,i,1,2]]}],p[[k,j,i,3]],"SVG"];"include::"<>p[[k,j,i,1,1]]<>"[]\n",{k,2},{j,2},{i,maxDegree+1}]},With[{file="approximation-sections.adoc"},Export[FileNameJoin[{includesPath,file}],StringJoin[includeStrings]<>"\n","Text"];Print["Here's the include statement to put into the top-level document:\n"<>"include::{includedir}/"<>file<>"[]"];]]]]];


(*CloseKernels[];*)


Print["generate-approximation-sections.wls: Done.\n"];
