require 'sinatra'
require 'sinatra/reloader'

enable :sessions

get '/' do
  @names = session[:names]
  @method = session[:method]
  @number = session[:number]
  @error = session[:error]
  if @error == "" and @names != ""
    @teams = session[:teams]
  end

  erb :index, layout: :template
end

post '/' do
  session[:names] = params[:names].split(",").map{|x| x.gsub(" ", "")}
  session[:method] = params[:method]
  session[:number] = params[:number]

  session[:error] = getErrorMsg(session[:number], session[:names])
  if session[:error] == ""
    #create teams
    session[:teams] = {}
    counter = 0
    #Fix team count
    if (session[:method]) == "Team Count"
      per_team = (session[:names].length / session[:number].to_i)
      team_count = session[:number].to_i
    else
      per_team = session[:number].to_i
      team_count = (session[:names].length / session[:number].to_i)
      team_count += 1 if(session[:names].length % session[:number].to_i != 0)
    end
    #break up names list into teams
    session[:names].shuffle.each_slice(per_team) { |team| session[:teams][counter +=1]=team.to_a }
    #fix uneven team distribution
    fix_counter = 0
    while session[:teams].length > team_count
        loser_team = session[:teams][counter]
        session[:teams].delete(counter)
        counter -= 1;
        for i in 1..loser_team.length
          session[:teams][i+fix_counter].push(loser_team[i-1])
        end
        fix_counter += 1
    end
  end

  redirect to "/"
end

def getErrorMsg(number, names)
  #error checking
  if names == []
    "Please enter some names"
  elsif number == ""     #No number entered
    "Please enter a number."
  elsif number == "0" #User entered 0
    "Please enter a number greater than zero."
  elsif number.to_i > names.length  #Number greater than number of names
    "Please enter a number less than the number of names."
  else        #Everything is good to go
    ""
  end
end
