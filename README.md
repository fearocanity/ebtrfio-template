<h1 align="center">Every <sup><sub><sub>(name)</sub></sub></sup> Frame in Order BOT</h1>

<div align="center">

`An OpenSource BOT for Facebook Frame in Order`<br>
`that runs without 24/7 hosting costs`

</div>

## Table of Contents
- [Tutorial](#tutorial)
  - [Setup FB Token](#setup-facebook-token)
  - [Setup Frames](#setup-the-frames)
  - [Setup your BOT](#setup-your-bot)
  - [How to make your Content Public](#how-to-make-your-content-public)
  - [How to Run the Bot Manually](#how-to-run-the-bot-manually)
  - [How to Manually Disable the Posting](#how-to-manually-enabledisable-the-posting)
- [Notes and Tips](#notes-and-tips)
- [Contributing](#contributing)
- [Status](#status)


## Tutorial
This section tells how to make it work. In more detailed way.

> Grammatical Errors ahead, we're not native english speaker so please bear with us.

### Setup Facebook Token
  <details>
  <summary>Click Here to Show</summary><p>
  
  To set up a Facebook long-lived access token, follow these steps:
  - Go to [Facebook Developer](https://developers.facebook.com/)
   - Click `My Apps`<p>
   ![Screenshot](https://user-images.githubusercontent.com/91414643/221354558-e2f22a89-33d6-4edb-9218-fb96aae7a9af.png)
   - Click `Create App`<p>
   ![Screenshot](https://user-images.githubusercontent.com/91414643/221354832-0649cfaa-2414-4530-ab5c-b0b8b732a9be.png)
   - Click `Business` and `Next`<sup><sub>(Business has more perks, than others so pick it)</sub></sup><p>
   ![image](https://user-images.githubusercontent.com/91414643/221354888-f7abb53d-7c88-4116-b89f-bda5e07e71bd.png)
  - This is very Self Explanatory, I guess you already know what to do.<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221354981-deb1fb14-1d64-45fa-aa91-e9b2797fe06f.png)
  - Hover through `tools` and Click `Graph Api Explorer`<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221355248-9e7de41c-a9c9-46d6-9b51-b4a084c3bddc.png)
  - Grant Permissions for token, Click `Add a Permission`, Then click `Events Groups Pages` click all the following
  ![Screenshot](https://user-images.githubusercontent.com/93582751/225804307-1b147266-4fc4-4b13-b35c-630ab2d70edb.png)
  > [!NOTE]
  > The scopes should be color `black` as the image shows, If it shows color `green` it means it's not yet applied to the token. (Repeat the proccess if the next step doesn't work)
  - Click on `User Token` and choose the page you want.<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221355474-107eaf3b-c9f7-4179-81cf-4cb4b58f396d.png)
  - There's gonna popup there, just give the App Permissions and Authorize it.
  - Now Click `Generate Access Token` and set the `User Token` to the page you want, then copy the Short-Lived-Token<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221355673-131f9bed-9828-4750-9366-2958e378bd37.png)
  - Go back to `Dashboard` Again. Then hover through `tools` and click `Access Token Debugger`<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221399431-f14c716f-c417-4c17-8cca-d6f8244caa19.png)
  - Insert the Token you copied earlier and Click `Extend Access Token`<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221356061-137ea679-5df4-4b89-aa18-0f734438d402.png)
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221356085-523a326a-8c01-4124-9101-408f9bcc2dfa.png)
  - Now Copy it and Save it Somewhere<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221356335-470d5ab6-5d28-44fa-92fc-eb6ccddce722.png)
  
  </details>

  ---

  ### Setup the Frames
  <details>
  <summary>Click Here to Show</summary><p>

  You need to use Windows Powershell to use program called `FFMPEG`

  We need to install Scoop First, before installing `FFMPEG`<p>
  To open `Windows Powershell`:
  - Click `Windows Button`
  - And Search for `Windows Powershell` then Right-Click and click `Run as Administrator` 
  
  After you open it, Run this command:<p>
  ```
  iwr -useb get.scoop.sh | iex
  ```
  > [!NOTE]
  > If theres an error occured, just run the command below and re-run the command above. <sup>(Disregard the command below if theres no error appeared)</sup>
  > ```
  > Set-ExecutionPolicy RemoteSigned -scope CurrentUser
  > ```

  Now Run this command, to install `FFMPEG` and `GIT`:
  ```
  scoop install ffmpeg git
  ```
  
  After succeeding, Now run these commands:
  ```
  md "$($env:USERPROFILE)\Desktop\frames"
  cd "$($env:USERPROFILE)\Desktop\frames"
  ```
  This folder will appear on your Desktop, And thats where you will replace your video you want to chop
  
  ![image](https://user-images.githubusercontent.com/91414643/221358390-3d1489f8-5514-4499-a4c9-50e57b7ce97d.png)

  Now chop the video by running this command:
  ```
  ffmpeg -i "video.mkv" -r 2 -q:v 3 frame_%00d.jpg
  ```
  - `-i "video.mkv"` input file
  - `-r 2` is the frames chopped per second <sup>(needed in `config.conf`)</sup>
  - `-q:v 3` quality
  - `frame_%00d.jpg` output file
  
  Wait until it finished... Then, we're gonna gather the infos of Video and Make sure to Take note all the infos needed.

  To get the total frames of the video. <sup>(You can see this info too while chopping the frames)</sup> 
  ```
  ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 video.mkv
  ```
  To get the frame rate of the video  <sup>(If you get fractions "24/1" omit "/1")</sup>
  ```
  ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 video.mkv
  ```
  
  Then now we're gonna upload the frames to GitHub.
  Open your `Windows Powershell` and Run the Command below:
  ```
  cd ..
  git clone https://github.com/{your_username_here}/{repo_name}
  ```
  > [!IMPORTANT]
  > Make sure that you already created a repository for this template. `{repo_name}` stands for the name of your repo you created for this template
  
  Now, Run this command:
  ```
  cd {repo_name}
  Copy-Item -Path "$($env:USERPROFILE)\Desktop\frames\frame_*.jpg" -Destination frames -Recurse
  git init
  git add .
  git commit -m "frames, update"
  ```
  Provide your Git Infos, Must be the same as your username and email <sup>(it will not display it on public)</sup>:
  ```
  git config --global user.name "<your-username>"
  git config --global user.email <your-email@gmail.com>
  ```
  
 Now get your GitHub token, refer to [this](https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) tutorial...
  
  - And finally, Push the changes to the repository:
  ```
  git remote set-url origin https://{your_username}:{your_token_here}@github.com/{your_username}/{repo_name}
  git push origin master
  ```

  </details>
  
  ---
  
  ### Setup your BOT
  
  <details>
  <summary>Click Here to Show</summary><p>
  
  - Add subtitle file <sup>(only supported **\*.ass/\*.ssa, \*.srt** subtitles)</sup>
  - Insert all the infos needed in `config.conf` file.
  ![Screenshot](https://user-images.githubusercontent.com/93582751/225806519-3b563df1-68f0-485c-9579-61dde2a74a4f.png)
  - And push it to master.
  
  We need to setup our repo secret variables too...
  
  - To setup it, first go to `Settings` on your GitHub Repo.<p>
  ![image](https://user-images.githubusercontent.com/91414643/221394421-9863b584-2a31-4faf-a7c0-a4913d68db52.png)
  - Under the `Secrets and Variables` section, Click `Actions`<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221394588-b88183ce-de54-461e-bc49-031891e5f84c.png)
  - Then click `New Repository Secret`<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221394694-c07449b0-c76e-44e1-94c0-fc3043090640.png)
  
  - The name must be `TOK_FB`, And Paste your Long-Live Facebook you save earlier, Then click `Add Secret`.<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221394973-d17f410b-f12a-47c4-bde2-6cb62f002f15.png)
    - (Optional) You can add the GIF token too by creating again, and it is named `TOK_GIF`<p>
  
  - Go to `Settings` again, Under `Actions`, click `General`<p>
  ![???](https://user-images.githubusercontent.com/91414643/221912286-c5e82432-a320-41bb-a516-c0856e35b25d.jpg)
  - Click `Read and Write Permission` and `save` it.<p>
  ![???](https://user-images.githubusercontent.com/91414643/221912865-4d638bde-d221-4d94-aaef-1e64b8988a2b.jpg)
  
  - Then you're good to go for a test now. You're Done!!
    
  </details>
  
  ---
  
  ### How to make your Content Public
  
  > [!IMPORTANT]
  > All the contents you post will not be shown to public if it not set to `Live`
  
  <details>
  <summary>Click Here to Show</summary><p>
  
  - Go to `Settings` > `Basic`<p>
  ![Screenshot](https://github.com/fearocanity/ebtrfio-template/assets/91414643/d4a426a9-bfdb-41d9-a02a-b2888f712369)
  
  - And Change your `Privacy Policy URL` to `https://google.com`, Then click `Save Changes` at the bottom of the page.<p>
  ![Screenshot](https://github.com/fearocanity/ebtrfio-template/assets/91414643/36ce8bbc-f558-4530-ae32-b2e3fb0765b6)
  ![Screenshot](https://github.com/fearocanity/ebtrfio-template/assets/91414643/303607a9-770c-47cf-9194-75a3e13bc7fd)

  - Then go back to the `Dashboard` and Switch your Transparency from Development to Live<p>
  ![Screenshot](https://github.com/fearocanity/ebtrfio-template/assets/91414643/00d46954-a38c-4249-9264-3265ea9f3d83)
    
  </details>
  
  ---
  
  ### How to Run the Bot Manually
  <details>
  <summary>Click Here to Show</summary><p>
  
  - Click on `Actions`<p>
  ![image](https://user-images.githubusercontent.com/91414643/221397334-bc392a43-4957-48d7-b001-abb1f9e0ba36.png)
  - Click on `init banner`, And click `Run Workflow`<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221397447-13ec2f97-6830-4600-87a1-390f7f473d5b.png)
  
   > [!WARNING]
   > We prefer not doing this *(The BOT is already running)*, because it will cause to run the workflow twice when the automatic run was executed. it'll cause duplication. Instead do [Manually Disable Workflow](#how-to-manually-enabledisable-the-posting). Make sure you know what you're doing. *(This is helpful if you want to run the posting after you enable the workflow)*

  </details>
  
  ---
  
  ### How to Manually Enable/Disable the Posting
  <details>
  <summary>Click Here to Show</summary><p>
  
  - Click on `Actions`<p>
  ![image](https://user-images.githubusercontent.com/91414643/221397334-bc392a43-4957-48d7-b001-abb1f9e0ba36.png)
  - Click on `init banner`, and click the three dots `···`. Then finally, click on `Disable Workflow`<p>
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221398101-a13b6416-dbb9-4cfa-bb34-3a95b330f210.png)
    
  > [!NOTE]
  > Enabling it pretty much the same procedure, It will appear the enable button at the top.
  </details>

  ---
  
  ### How to Change the Interval execution of Posting

  <details>
  <summary>Click Here to Show</summary><p>

  - Firstly, go to `.github/workflows/process.yml`
  ![Screenshot](https://github.com/fearocanity/ebtrfio-template/assets/91414643/77fd6f00-c350-4a68-bfdc-40ff8d3c8658)

  - And change the cron syntax `0 */2 * * *`, this cron syntax stands for `every 2 hrs`, so you can just change the `2` based on your likings. Or you can make your own cron [here](https://crontab.guru/).

  > [!WARNING]
  > Make sure you know what you're doing, This might cause duplications and errors on posting. And before you adjust it, make sure the product of `fph` and `mins` mustn't exceed to the number of hours you set on cron.
>  Assume you have `fph=50` and `mins=5`, so the product of it is: `50 * 5 = 250`, then divide it with 60 to know the number of hours: `250 / 60 = 4.16 hrs`


  </details>

  ## Notes and Tips

  > [!NOTE]
  > - By Default, the bot will automatically run every 2 hrs. <sup>(This is our Standard Interval posting)</sup>
  > - We recommend to use `Use this Template` button rather than forking this repository.
  > - We recommend Creating a Pull Request when you're setupping frames for next episode/series to track your changes and guides you on what steps you will take.
  > - Make sure not to push something in master while the BOT is running. Wait it to be finished first to avoid duplicatiom issues.
  > - Keep your repository updated with [parent repository](https://github.com/fearocanity/ebtrfio-template) for fixes and security measure updates.
  > - When proceeding to a new Episode, you should create a Pull Request to your repo. <sup>(Don't forget `frameiterator` to change back to `1`)</sup>
  > - Use `action/repo-checker` as your basis for checking errors and misconfiguration.
  > - Recommended source: `Erai-Raws`, `Nyaa`.
  > - If you need help, just message us on our [<sub><img src="https://camo.githubusercontent.com/8f245234577766478eaf3ee72b0615e99bb9ef3eaa56e1c37f75692811181d5c/68747470733a2f2f6564656e742e6769746875622e696f2f537570657254696e7949636f6e732f696d616765732f7376672f66616365626f6f6b2e737667" height="20"></sub> Facebook](https://facebook.com/btrframes) page. Or create an Issue/Discussion thread here.
  > - When using a VPS/Droplet server, just clone this repository and paste all your frames to `frames` directory, also the tokens are gonna be in `secret.sh` file.


  > [!WARNING]
  > We're not responsible whatever happens to your Facebook account. Just to be safe, I prefer using an dedicated account for the page, else you can use your main but use it with care. *Use at your own risk*

## Contributing
<div align="center">

```diff
+ All PR's are now welcome!! +
```
If you have ideas or fixes to the bugs and also improving the codes, Feel free to [Contribute](./CONTRIBUTING.md)! 😉
</div>

## Status
![Status Image](status/status.png)
