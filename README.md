# Every ◯◯ Frame in Order BOT
This is where we run our BOT.

# Table of Contents
- [Tutorial](#tutorial)
  - [Setup FB Token](#setup-facebook-token)
  - [Setup Frames](#setup-the-frames)
  - [Setup your BOT](#setup-your-bot)
  - [How to Run the Bot Manually](#how-to-run-the-bot-manually)
  - [How to Manually Disable the Posting](#how-to-manually-disable-the-posting)
- [Status](#status)


## Tutorial
This section tells how to make it work. In more detailed way.
### Setup Facebook Token
  <details>
  <summary>Click Here to Show</summary>
  
  To set up a Facebook long-lived access token, follow these steps:
   - Click `My Apps`
   
   ![Screenshot](https://user-images.githubusercontent.com/91414643/221354558-e2f22a89-33d6-4edb-9218-fb96aae7a9af.png)
   
   - Click `Create App`
    
   ![Screenshot](https://user-images.githubusercontent.com/91414643/221354832-0649cfaa-2414-4530-ab5c-b0b8b732a9be.png)

   - Click `Business` and `Next`

   ![image](https://user-images.githubusercontent.com/91414643/221354888-f7abb53d-7c88-4116-b89f-bda5e07e71bd.png)

  - This is very Self Explanatory, I Guess you already know what to do.
   
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221354981-deb1fb14-1d64-45fa-aa91-e9b2797fe06f.png)

  - Hover Through `tools` and Click `Graph Api Explorer`

  ![Screenshot](https://user-images.githubusercontent.com/91414643/221355248-9e7de41c-a9c9-46d6-9b51-b4a084c3bddc.png)

  - Click on `User Token` and choose the page you want.

  ![Screenshot](https://user-images.githubusercontent.com/91414643/221355474-107eaf3b-c9f7-4179-81cf-4cb4b58f396d.png)

  - Theres gonna popup there, just give the App Permissions and Authorize it.

  - Now Click `Generate Access Token` then Copy the Short-Lived-Token
  
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221355673-131f9bed-9828-4750-9366-2958e378bd37.png)

  - Go back to `Dashboard` Again. Then Hover through `tools` and click `Access Token Debugger`

  ![Screenshot](https://user-images.githubusercontent.com/91414643/221399431-f14c716f-c417-4c17-8cca-d6f8244caa19.png)


  - Insert the Token you copied earlier and Click `Extend...`
  
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221356061-137ea679-5df4-4b89-aa18-0f734438d402.png)
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221356085-523a326a-8c01-4124-9101-408f9bcc2dfa.png)

  - Now Copy it and Save it Somewhere

  ![Screenshot](https://user-images.githubusercontent.com/91414643/221356335-470d5ab6-5d28-44fa-92fc-eb6ccddce722.png)
  
  </details>
  
  ---

  ### Setup the Frames
  <details>
  <summary>Click Here to Show</summary>
  
  First, You need the Frames first, you would need a Windows Powershell to use program called `FFMPEG`

  We need to install Scoop First, to install `FFMPEG`<p>
  To open `Windows Powershell`:
  - Click `Windows Button`
  - And Search for `Windows Powershell` then Right-Click and click `Run as Administrator` 
  
  After you open it, Run this command:
  ```
  iwr -useb get.scoop.sh | iex
  ```
  > **Note**: If theres an error occured, just run the command below (Disregard the command below if theres no error appeared)
  > ```
  > Set-ExecutionPolicy RemoteSigned -scope CurrentUser
  > ```

  Now Run this command, to install `FFMPEG`:
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
  - `-r 2` is the frames per second
  - `-q:v 3` quality
  - `frame_%00d.jpg` output file
  
  Wait until it finished... Then, we're gonna gather the infos of Video and Make sure to Take note all the infos needed.

  To get the total frames of the video.
  ```
  ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 video.mkv
  ```
  To get the frame rate of the video  (If you get fractions "24/1" omit "/1")
  ```
  ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 video.mkv
  ```
  
  Then now we're gonna upload the frames to GitHub.
  Open your `Windows Powershell` and Run the Command below:
  ```
  cd ..
  git clone https://github.com/{your_username_here}/ebtrfio-template
  ```
  > **Note**: Make sure that you already forked or created this repository
  
  Now, Run this command:
  ```
  cd ebtrfio-template
  Copy-Item -Path "$($env:USERPROFILE)\Desktop\frames\frame_*.jpg" -Destination frames -Recurse
  git init
  git add .
  git commit -m "frames, update"
  ```
  Provide your Git Infos, Must be the same as your username and email (it will not display it on public):
  ```
  git config --global user.name "<your-username>"
  git config --global user.email <your-email@gmail.com>
  ```
  
 Now get your GitHub token, refer to [this](https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) tutorial...
  
  - And finally, Push the changes to the repository:
  ```
  git remote set-url origin https://{your_username}:{your_token_here}@github.com/{your_username}/ebtrfio-template
  git push origin master
  ```

  </details>
  
  ---
  
  ### Setup your BOT
  
  <details>
  <summary>Click Here to Show</summary>
  
  - Add subtitle file (only supported **\*.ass** subtitle)
  - Insert all the infos needed in `config.conf` file.
  ![image](https://user-images.githubusercontent.com/91414643/221393080-91011934-63d2-41f0-98ee-0e71ffec2eda.png)
  - And push it to master.
  
  We need to setup our repo secret variables too...
  
  - To setup it, first go to `Settings` on your GitHub Repo.
  
  ![image](https://user-images.githubusercontent.com/91414643/221394421-9863b584-2a31-4faf-a7c0-a4913d68db52.png)
  - Under the `Secrets and Variables` section, Click `Actions`
  
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221394588-b88183ce-de54-461e-bc49-031891e5f84c.png)
  - Then click `New Repository Secret`
  ![Screenshot 2023-02-26 135209](https://user-images.githubusercontent.com/91414643/221394694-c07449b0-c76e-44e1-94c0-fc3043090640.png)
  
  - The name must be `TOK_FB`, And Paste your Long-Live Facebook you save earlier, Then click `Add Secret`.
  - (Optional) You can add the GIF token too by creating again, and it is named `TOK_GIF`

  > Your tokens are secured by GitHub, See Documentation: [Here](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
  
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221394973-d17f410b-f12a-47c4-bde2-6cb62f002f15.png)

  - Then you're good to go for a test now.
  </details>
  
  ---
  
  ### How to Run the Bot Manually
  <details>
  <summary>Click Here to Show</summary>
  
  - Click on `Actions`
  
  ![image](https://user-images.githubusercontent.com/91414643/221397334-bc392a43-4957-48d7-b001-abb1f9e0ba36.png)
  
  - Click on `init banner`, And click `Run Workflow`
  
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221397447-13ec2f97-6830-4600-87a1-390f7f473d5b.png)
  
   > **Warning**: I prefer not doing this (The BOT is already running), because it will cause to run the workflow twice when the automatic run was executed. it'll cause duplication. Instead do [Manually Disable Workflow](#how-to-manually-disable-the-posting)

  </details>
  
  ---
  
  ### How to Manually Disable the Posting
  <details>
  <summary>Click Here to Show</summary>
  
  - Click on `Actions`
  
  ![image](https://user-images.githubusercontent.com/91414643/221397334-bc392a43-4957-48d7-b001-abb1f9e0ba36.png)
  
  - Click on `init banner`, and click the three dots `···`. Then finally, click on `Disable Workflow`
  
  ![Screenshot](https://user-images.githubusercontent.com/91414643/221398101-a13b6416-dbb9-4cfa-bb34-3a95b330f210.png)
    
  > **Note**: In enabling its pretty much the same procedure, It will appear the enable button at the top.
  </details>

  ## Notes and Tips
  - In Default, the bot will automatically run every 2 hrs (This is my Standard Interval posting)
  - When proceeding to a new Episode, you should create a Pull Request to your repo and change `frameiterator` back to `0`, and manually editing the `config.conf` to change all the infos there.
  - You need to 
  
## Status
![Status Image](status/status.jpg)
