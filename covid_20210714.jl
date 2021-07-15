using Blink, Interact, Plots, WebIO, GraphRecipes,CSV,DataFrames, Dates, DynamicalSystems


urli = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
#urld = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
#urlr = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"
download(urli,"covid_infected.csv")
readdir()
#datai = CSV.read("covid_infected_20210712.csv",DataFrame);
datai = CSV.read("covid_infected.csv",DataFrame);
einw = CSV.read("einwohner.csv",DataFrame);
rename!(datai,1 => "province", 2 => "country")
countries = collect(datai[:,2])
provinces = collect(datai[:,1])
contrprov = collect(datai[:,2])
#data_cum = collect(datai[:,5:])
einwl = collect(einw[:,1])
einwz = collect(einw[:,2])
datainc = datai
names_df = names(datai)



extract_country = "a"
unique_countries = unique(countries)

for i in 1:length(countries)
    if ismissing(provinces[i])
        pro = ""
    else
        pro = " " * provinces[i]
    end
#   contrprov[i] = countries[i]  
    contrprov[i] = countries[i] * pro 
end

numdat = length(collect(datai[1,:]))-4
numcountr = length(unique_countries)

unique_countries_sort_rate = Array{String, 1}(undef,numcountr)
unique_countries_sort_inc = Array{String, 1}(undef,numcountr)
index_uniq = Array{Int, 1}(undef,numcountr)
val_array = Array{Float64, 1}(undef,numdat)
data_extr_unique = Array{Int, 2}(undef,numcountr,numdat)
#@show countries
unique_countries = unique(countries)
#@show unique_countries


#for i in 125:128
for i in 1:numcountr
#    @show unique_countries[i]
    index_all = findall(x -> x==unique_countries[i] , countries)
    lenindall = length(index_all)
#    @show i index_all lenindall
    if lenindall == 1 
        index_uniq[i] = findfirst(x -> x==unique_countries[i] , countries)
    else
#        @show unique_countries[i], index_all
        for j5 = 1:lenindall   
             index_uniq[i] = 0
#              @show countries[index_all[j5]] provinces[index_all[j5]]
            if ismissing(provinces[index_all[j5]])
                index_uniq[i] = index_all[j5]
            end
        end
    end
#    @show i numdat index_uniq[i] unique_countries[i]
    if index_uniq[i] == 0
        for k4 in 1:numdat
          data_extr_unique[i,k4] = 0
#             @show i k4
            for l1 in 1:lenindall
#                @show l1  index_all[l1] datai[index_all[l1],k4+4]
                val_array = collect(datai[index_all[l1],:])
                val = val_array[k4+4]
#               @show  val
                data_extr_unique[i,k4] = data_extr_unique[i,k4] + val
            end
        end
        index_uniq[i] = index_uniq[i-1]+1
#         @show  i index_uniq[i]
    else
      data_extr_unique[i,:] = collect(datai[index_uniq[i],5:end])
    end
end
#@show numcountr numdat data_extr_unique[numcountr,numdat]

data_last_rate= Array{Int, 2}(undef,numcountr,2)
data_sort_rate= Array{Int, 2}(undef,numcountr,2)
data_last_inc= Array{Float64, 1}(undef,numcountr)
data_sort_inc= Array{Float64, 2}(undef,numcountr,2)
#@show numcountr,numdat
#@show  length(data_last_inc)
#@show length(einwz)
#@show  data_extr_unique

for k4 in 1:numcountr
    numdat1 = numdat - 1
#    @show numdat numdat1 data_extr_unique[k4,numdat] data_extr_unique[k4,numdat1]
     data_last_rate[k4,2] = data_extr_unique[k4,numdat] - data_extr_unique[k4,numdat1]
     data_last_rate[k4,1] = index_uniq[k4]

     data_last_inc[k4] = 0
     sum = 0
     for i5 in 1:7
#        @show i5 sum data_extr_unique[k4,numdat+1-i5] data_extr_unique[k4,numdat-i5]
         sum = sum + data_extr_unique[k4,numdat+1-i5] - data_extr_unique[k4,numdat-i5]
     end
#    @show sum
   for i6 in 1:length(einwz) 
      if einwl[i6] ==  unique_countries[k4]  
#        @show k4, unique_countries[k4], i6, einwl[i6], einwz[i6]        
        if einwz[i6] == 0
          data_last_inc[k4] = 0
        else
          
          data_last_inc[k4] = sum/float(einwz[i6])*100000.
        end
#        @show   sum, data_last_inc[k4]
      end
    end
end
#@show data_last_inc
#@show data_last_rate

#data_sort_rate = sort!(data_sort_rate, dims=1, rev=true)
#data_sort_rate = sortslices(data_sort_rate, dims=2)
#A[sortperm(A[:, 4]), :] # sorted by the 4th column



date_names = String.(names(datai[1,5:end]))

numland = length(index_uniq)
date_names
index_uniq
#@show data_last_rate[:,2]
#@show data_last_inc
sortind1 = sortperm(data_last_rate[:,2],rev=true)
sortind2 = sortperm(data_last_inc,rev=true)
#sortind = index_uniq[sortind1]
#@show unique_countries
#@show sortind1
#for i5 in 125:127
#@show numland
for i8 in 1:numland
#    @show i8
    data_sort_rate[i8,1] = sortind1[i8]
    data_sort_rate[i8,2] = data_last_rate[sortind1[i8],2]    
    data_sort_inc[i8,1] = sortind2[i8]
    data_sort_inc[i8,2] = data_last_inc[sortind2[i8]]
    unique_countries_sort_rate[i8] =  unique_countries[sortind1[i8]]
    unique_countries_sort_inc[i8] =  unique_countries[sortind2[i8]]
end



#length(unique_countries)

#data_sort_rate
#unique_countries_sort;
#sortind2
#data_sort_inc
unique_countries_sort_inc

function create_plots(i,countr,dict1)
@show dict1, i,countr  

if dict1 == 0
#    index = index_uniq[i]
    index = i
else
    if dict1 == 1
        index = sortind1[i]
    else
        index = sortind2[i]
    end
end
extract_country = countr
#extract_country = xx[2]
    
@show extract_country      



index_einw = findfirst(x -> x==extract_country , einwl)
einwz[index_einw]
    
data_extr = data_extr_unique[index,:]
countryname =  unique_countries[index]
lendat = length(data_extr)
@show lendat  
    
if data_extr[1] <= 0
        data_extr[1] = 1
end
for i1 in 2:lendat
    if data_extr[i1] <= 0
        data_extr[i1] = data_extr[i1-1]
    end
end
#    @show data_extr  

data_extr_rate = Array{Int, 1}(undef,lendat)
data_incidence = Array{Float64, 1}(undef,lendat) 
data_extr_avg = Array{Float64, 1}(undef,lendat)
data_extr_rate[1] = 0
for i2 in 2:lendat
    data_extr_rate[i2] = data_extr[i2] - data_extr[i2-1]
    if data_extr_rate[i2] < 0
        data_extr_rate[i2] = 1
    end
#    @show i2 data_extr_rate[i2] data_extr[i2] data_extr[i2-1]
end
# @show data_extr_rate
#@show index_einw, einwz[index_einw]
for i3 in 1:6
    data_extr_avg[i3] = 0
    data_incidence[i3] = 0
end
for i4 in 7:lendat
    sum = 0
    for i5 in 1:7
        sum = sum + data_extr_rate[i4-i5+1]
    end
    if einwz[index_einw] == 0
            data_incidence[i4] = 0
        else
            data_incidence[i4] = sum/einwz[index_einw]*100000.
        end
    sum = sum/7
    data_extr_avg[i4] = sum
end
# @show data_incidence

dates = date_names
#dfinc =  DataFrame(land=contrprov, inc=data_incidence)


#@manipulate for i in 1:length(data_extr)
#  HTML(data_extr[i])
#end
#findall.(extr_country,contrprov)
#findall(occursin.(query,contrprov))
format = Dates.DateFormat("m/d/YY")
datesplot = parse.(Date,dates,format).+Year(2000)
p1=plot(datesplot,data_extr_rate,xticks=datesplot[1:90:end], leg=:topleft, 
#p1=plot(datesplot,data_sort_rate,xticks=datesplot[1:90:end], leg=:topleft, 
        label=string(extract_country)*": "*string(data_extr_rate[end]), ylim=(0.,),
        title="Bestätigte COVID-Infektionen",ylabel="COVID-Infektionen pro Tag",
        color = :lightgreen,fill = (0, 0.5, :lightgreen))
p2=plot!(datesplot,data_extr_avg,label="7-Tage-Mittel", ylim=(0.,),color = :black,linewidth = 2)
  inz =  round.(Int,data_incidence[numdat])
p3=plot(datesplot,data_incidence,xticks=datesplot[1:90:end],label="Inzidenz: "*string(inz),
    leg=:topleft,title="Inzidenz "*string(extract_country),ylabel="Inzidenz",
            color=:blue,fill = (0, 0.5, :red),linewidth = 2,background_color = :ivory)


    
plot(p1,p3,layout=(2,1),size=(750, 450))
    
#background_color{RGB(0,5;)}
#button("sort")
#xlabel!("Datum")
#ylabel!("COVID-Infektionen pro Tag")
#plotattr(:Series)
#plotattr(:Subplot)
#plotattr(:Axis)
#plotattr("background_color")    
#plotattr(:Plot)
#background_color, background_color_outside, display_type, dpi, extra_kwargs, extra_plot_kwargs, fontfamily, foreground_color, html_output_format, inset_subplots, layout, link, overwrite_figure, plot_title, plot_title_location, plot_titlefontcolor, plot_titlefontfamily, plot_titlefonthalign, plot_titlefontrotation, plot_titlefontsize, plot_titlefontvalign, pos, show, size, tex_output_standalone, thickness_scaling, warn_on_unsupported, window_title
end


#sort_auswahl = 0
#s = @manipulate throttle=1.0 for i in 1:length(unique_countries)
 s = @manipulate for i=slider(1:length(unique_countries), value=1), 
    sort_auswahl= Dict("sort Inzidenz" => 2, "sort Tagesänderung" => 1,"no sort" => 0 )
#    i,contrprov[i]
    #@manipulate for i=slider(1:10, value=3)

#    i
#    println(i,contrprov[i])
   
    @show sort_auswahl
#    @show unique_countries_sort
    if sort_auswahl == 0
        create_plots(i,unique_countries[i],sort_auswahl)
    else
        if sort_auswahl == 1
           create_plots(i,unique_countries_sort_rate[i],sort_auswahl)
        else
            @show i, sort_auswahl, unique_countries_sort_inc[i]
           create_plots(i,unique_countries_sort_inc[i],sort_auswahl)
        end       
    end
end
   w = Window()
   body!(w,s)
#@manipulate for i=slider(1:10, value=3)
#   i
#end    
#@manipulate for i in 1:length(data_extr)
#  HTML(data_extr[i])
#end




