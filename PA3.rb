#program Name: Movie_data search
#  program idea:the program read multiple files and then try to serach for user that has the same demographic inforamtion
# also the program cabable to search for movies depend on title and genre also the program try to find the movie that released in particluar
#year and try to find the best viewer movie among people with spical demographic
#Author Name:Fatima Abu Deeb
# this program read data from u.data file , u.item , u.occupation ,u.genre ,u.user

# class movie to sotore the information for each movie
class Movie
  attr_accessor :movie_id ,:movie_name,:movie_date,:movie_genre;
  # constructor to intlize the movie_test varabile
  def initialize movie_id,movie_name,movie_date,movie_genre
   @movie_id=movie_id
   @movie_name=movie_name
   @movie_date=movie_date
   @movie_genre=movie_genre
  end
end
# calss user to store the information for each user
class User
	attr_accessor :user_id,:u_age,:u_accoupation,:u_sex
	def initialize user_id=nil,u_age=0,u_accoupation=nil,u_sex=nil
		@user_id=user_id
		@u_age=u_age
		@u_accoupation=u_accoupation
		@u_sex=u_sex
	end
end
# moviedata to perform some search on the movie and user
class MovieData
	attr_accessor :movies ,:users,:genre,:occupation,:user_movie
	def initialize 
    populategenra() # method to pouplate genre list instance variable 
		pouplatemovies()# method to poplate  movies list instance variable
    pouplateusers() # method to populate users list instance variable
    @user_movie=read # methdo to populate user with the movie they watch 
	end

  #==================================================
  # methdo to populate user with the movie they watch 
  #=================================================
  def read 
    user_movie=Hash.new{|hash, key| hash[key] = Array.new}
    File.open("u.data","r") do |file|
    while (line = file.gets)
      data=line.split(" ") # split the line by placeholder " "
      user_movie[data[0]].push(data[1])
    end
   end
    return user_movie
  end
#===========================================
#method to populate users list instance variable with users object
#========================================
def pouplateusers
  users=Array.new
  File.open("u.user","r") do |file|
  while (line = file.gets)
    if(line.chomp.length!=0)
      data=line.split("|")
      users.push(User.new data[0],data[1].to_i,data[3],data[2])
    end
  end
end
 @users=users
end
#=======================================================
# method to populate movies list instance variable with movie objects
#======================================================
def pouplatemovies
  movies=Array.new
  File.open("u.item","r") do |file|
  while (line = file.gets)
    if(line.chomp.length!=0)
      if line.include? ("unknown||||")
      else
     data=line.split("||")
     first=data[0].split("|")
     date=first[2].split("-")
     date= date[2].to_i
     second=data[1]
     second =second.split("|")
     types=second[1 .. second.length-1]
     movies.push(Movie.new first[0],first[1],date,generarray(types))
     end
    end
  end 
end
 @movies=movies 
end
#==============================================================
#method to return genra array for each movie  
# genra is value 0-18 
#===================================================
def generarray genre
  result=Array.new
  count=-1
  genre.each do |x|
    count+=1;
    if x.include? "1"
      result.push count
    end
  end
  return result
end
#++++++++++++++++++++++++++++++++++++
#===pouplate genra list
def populategenra
File.open("u.genre","r") do |file|
  genre=Hash.new
  while (line = file.gets)
    if(line.chomp.length!=0)
      data=line.split("|") # split the line by placeholder " "
      genre[data[0]]=data[1].chomp
    end
  end
end
@genre=genre    
 end 
 #===================================
 # method to return movie depend on charstrastic 
 #+====================================
 def find_movies(hash)
  resultmovies=Array.new
  @movies.each do |movie|
    if movie.movie_name.downcase.include? hash["title"].downcase
      if movie.movie_genre & hash["genre"]==hash["genre"]
        resultmovies.push movie
      end
   end
 end 
 return resultmovies
end
#=======================================================
# user to populate occupation form u.occupation db
#==================================================
def user_occupation 
  ocu=Array.new
 File.open("u.occupation","r") do |file|
   while (line = file.gets)
    if(line.chomp.length!=0)
     ocu.push(line.chomp)
   end
 end
 end
 @occupation=ocu
 return ocu
end
#===============================================
# find_users with special characstitc 
#===============================================
def find_users(hash) 
  resultusers=Array.new
  age_r=hash["age"]
  @users.each do |user|
    if hash["occupation"]==nil
      x=true
    else
      x=user.u_accoupation.include? @occupation[hash["occupation"]]
    end
    if hash["age"]==nil
      y=true
     else
     y= user.u_age >= age_r[0] && user.u_age <= age_r[1]
    end
    if x
     if y
       if user.u_sex .include? hash["sex"]
        resultusers.push user
       end
      end
    end
  end # do if
 return resultusers
end
#===================================
# return the movies with that genra that release on spesfied year 
def test1 (genre,year)
  begining_time=Time.now
  resultmovies=Array.new
  hash=Hash.new
  hash["title"]=""
  hash["genre"]=genre
  movies=find_movies(hash)
  movies.each do |movie|
    if movie.movie_date==year
      resultmovies.push(movie)
    end
  end
  end_time=Time.now
puts "Time elapsed to compute test1 is #{(end_time - begining_time)} seconds"
return resultmovies
end
#==============================================
# return the the most n movies that watch by one sex in age range
def test2(agerange,sex,n)
  #========return the users ids'
 beginning_time = Time.now
 u_id=Array.new
 hash=Hash.new
 hash["sex"]=sex
 hash["age"]=agerange
 find_users(hash).each do |user1|
  u_id.push user1.user_id
 end
  #====== return the movies_id no
   movie_no=moviesids u_id
   #=======return the most movies id and then 
   # call moviesname to return the names 
    movie_no= Hash[movie_no.sort_by{|m,p| -p}]
    movie_names=Array.new
    movie_no.keys[0..n-1].each do |no|
    movie_names.push(moviename(no))
   end
   end_time = Time.now
   puts "Time elapsed #{(end_time - beginning_time)} seconds"
  return movie_names
  end
  # return the movie name of movie Id 
def moviename(id)
  m_name=""
  @movies.each do |m|
    if m.movie_id==id
      m_name=m.movie_name
     break
    end
  end
  return m_name
end
# return the movies ids
def moviesids (u_id)
  movie_no=Hash.new
  @user_movie.each do |k,v|
    if u_id & [k]==[k]
      v.each do |m_id|
        if(movie_no[m_id].nil?)
          movie_no[m_id]=1
        else
          movie_no[m_id]=movie_no[m_id]+1;
        end
     end # end do 
     end# end if 
   end# end do 
   return movie_no
  end # end method
end # end of the class
movie_data=MovieData.new
puts "find the top five most viewed movies by college age females"
serchresult=movie_data.test2([18,30],"F",5)
serchresult.each do |b|
  puts b.inspect
end
puts "===================================================="
puts "find the top five most viewed movies by college age male"
serchresult=movie_data.test2([18,30],"M",5)
serchresult.each do |b|
  puts b.inspect
end
puts "===================================================="
 puts "find all SciFi movies released in 1996"
 searchresult=movie_data.test1([15],1996)

if searchresult.length == 0
   puts " there is no movie in that year realeaseed"
 else
 searchresult.each do |x|
  puts x.movie_name
end 
end
puts "===================================================="