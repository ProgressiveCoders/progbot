
[1mFrom:[0m /home/sukey/code/progcode/progbot/app/controllers/sessions_controller.rb @ line 19 SessionsController#create:

     [1;34m5[0m: [32mdef[0m [1;34mcreate[0m
     [1;34m6[0m:   @user = [1;34;4mUser[0m.find_or_create_by([35memail[0m: auth[[31m[1;31m'[0m[31minfo[1;31m'[0m[31m[0m][[31m[1;31m'[0m[31muser[1;31m'[0m[31m[0m][[31m[1;31m'[0m[31memail[1;31m'[0m[31m[0m])
     [1;34m7[0m:     [32mif[0m !@user.slack_userid
     [1;34m8[0m:       @user.slack_userid = auth[[31m[1;31m'[0m[31muid[1;31m'[0m[31m[0m]
     [1;34m9[0m:     [32mend[0m
    [1;34m10[0m:     [32mif[0m !@user.slack_username
    [1;34m11[0m:       @user.slack_username = auth[[31m[1;31m'[0m[31minfo[1;31m'[0m[31m[0m][[31m[1;31m'[0m[31muser[1;31m'[0m[31m[0m]
    [1;34m12[0m:     [32mend[0m
    [1;34m13[0m:     [32mif[0m @user.save
    [1;34m14[0m:       session[[33m:uid[0m] = @user.id
    [1;34m15[0m:       redirect_to welcome_dashboard_path
    [1;34m16[0m:     [32melse[0m
    [1;34m17[0m:       redirect_to new_users_path
    [1;34m18[0m:       session[[33m:params[0m] = auth
 => [1;34m19[0m:       binding.pry
    [1;34m20[0m:       [1;34m# fix this when find signup form path[0m
    [1;34m21[0m:     [32mend[0m
    [1;34m22[0m: [32mend[0m

