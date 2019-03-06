#!/usr/bin/env wolframscript
(* ::Package:: *)

Print["generate-error-summary-plot.wls: Started."];


directory=Directory[];


LaunchKernels[];


ClearAll[getApproximationCoefficients];
getApproximationCoefficients[s_String,relative_/;BooleanQ@relative,sine_/;BooleanQ@sine]:=With[{outPrecision=36,inPrecision=96},
Block[{$MinPrecision=outPrecision},SetPrecision[SetPrecision[ToExpression[StringReplace["{"<>s<>"}","e"->"*^"]],inPrecision],outPrecision]]];


With[{outfilesPath=FileNameJoin[{directory,"outfiles"}],maxDegree=16},coefficients=Table[With[{file=FileNameJoin[{outfilesPath,k<>"-"<>IntegerString[i,10,2]<>"-"<>j<>".txt"}]},getApproximationCoefficients[StringSplit[Import[file,"String"],{"[","]"}][[2]],j=="relative",k=="sine"]],{k,{"sine","cosine"}},{j,{"relative","absolute"}},{i,0,maxDegree}]];


Print["Generating plot\[Ellipsis]"];


With[{outPrecision=36,sd=Range[1,33,2],cd=Range[0,32,2]},
Block[{$MinPrecision=outPrecision},With[{
errs=Function[ai,With[{f=With[{h=HornerForm[Sum[ai[[i]] (2 Pi)^(i 2-1)#^(i 2-1),{i,Length[ai]}]]},Function[h]]},Quiet[{NMaxValue[{Abs[f[x]/Sin[x 2 Pi]-1],x>0+10^(-outPrecision),x<1/4-10^(-outPrecision)},x,PrecisionGoal->outPrecision,WorkingPrecision->outPrecision,MaxIterations->100],NMaxValue[{Abs[f[x]-Sin[x 2 Pi]],x>0+10^(-outPrecision),x<1/4-10^(-outPrecision)},x,PrecisionGoal->outPrecision,WorkingPrecision->outPrecision,MaxIterations->100]},{NMaxValue::cvdiv}]]],
errc=Function[ai,With[{f=With[{h=HornerForm[Sum[ai[[i]] (2 Pi)^(i 2-2)#^(i 2-2),{i,Length[ai]}]]},Function[h]]},Quiet[{NMaxValue[{Abs[f[x]/Cos[x 2 Pi]-1],x>0+10^(-outPrecision),x<1/4-10^(-outPrecision)},x,PrecisionGoal->outPrecision,WorkingPrecision->outPrecision,MaxIterations->100],NMaxValue[{Abs[f[x]-Cos[x 2 Pi]],x>0+10^(-outPrecision),x<1/4-10^(-outPrecision)},x,PrecisionGoal->outPrecision,WorkingPrecision->outPrecision,MaxIterations->100]},{NMaxValue::cvdiv}]]]},list=Transpose[{Join[Table[sd,4],Table[cd,4]],Join[Transpose[ParallelMap[errs,coefficients[[1,1]]]],Transpose[ParallelMap[errs,coefficients[[1,2]]]],Transpose[ParallelMap[errc,coefficients[[2,1]]]],Transpose[ParallelMap[errc,coefficients[[2,2]]]]]},{3,1,2}]]]];


plot=With[{c=With[{cl=ColorData[97,"ColorList"]},Function[i,cl[[i]]]]},ListLogPlot[list[[{1,2,3,4,5,6,8}]],PlotMarkers->{Automatic,15},Joined->True,GridLines->{Range[0,33],Automatic},Ticks->{Range[0,33],All},PlotStyle->{{c[1]},{c[2],Dotted},{c[3],DotDashed},{c[4],Dashed},{c[5]},{c[6],Dotted},{c[7],Dashed}},ImageSize->560,AspectRatio->1,PlotLegends->Placed[Flatten[Table["Max. "<>If[j,"rel.","abs."]<>" error of "<>If[k,"","co"]<>"sine approximation with minimized "<>If[i,"rel.","abs."]<>" error",{k,{True,False}},{i,{True,False}},{j,{True,False}}]][[{1,2,3,4,5,6,8}]],{.4,.17}],Epilog->Inset[ListLogPlot[list[[{1,2,3,4,5,6,8}]],PlotRange->{{13,16},{10^-16.5,10^-13}},PlotMarkers->{Automatic,15},Joined->True,GridLines->{Range[0,33],10^Range[-20,-10]},FrameTicks->{{All,None},{All,None}},PlotStyle->{{c[1]},{c[2],Dotted},{c[3],DotDashed},{c[4],Dashed},{c[5]},{c[6],Dotted},{c[7],Dashed}},ImageSize->240,AspectRatio->1,Background->Hue[0,0,1,.9],Frame->True,FrameLabel->{"Degree","Error"}],{Right,Top},{16.2,Log[10^-12.72]}]]];


Export[FileNameJoin[{directory,"images","error-summary-plot.svg"}],plot,"SVG"]


CloseKernels[];


Print["generate-error-summary-plot.wls: Done."];
