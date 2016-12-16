#!/usr/bin/perl
#  backup

$Main_Backup_Dir='/mnt/tb2/privy/backups/';
$username_dir='/home/zymos';
$username='zymos';

$Tmp_Backup_Dir='/tmp';
$RSYNC_PARAM='--archive --max-size="10M"  --progress';


$RSYNC_EXCLUDE="--exclude \".wine/drive_c\" \\\
--exclude \".ccache\" \\\
--exclude \".cache\" \\\
--exclude \".mozilla/firefox/\" \\\
--exclude \".opera/cache4\" \\\
--exclude \".gqview/metadata\" \\\
--exclude \".gqview/thumbnails\" \\\
--exclude \".thumbnails\" \\\
--exclude \".daimonin/cache\" \\\
--exclude \".gimp-2.6/tmp\" \\\
--exclude \".gimp-2.8/tmp\" \\\
--exclude \".local/share/Trash\" \\\
--exclude \".opera/images\" \\\
--exclude \".opera/vps\" \\\
--exclude \".opera/cache\" \\\
--exclude \".perltrash\" \\\
--exclude \".wesnoth\" \\\
--exclude \".winetrickscache\" \\\
--exclude \".VirtualBox/HardDisks\" \\\
--exclude \".VirtualBox/Machines/*/Snapshots\" \\\
--exclude \".asc/asc2.cache\" \\\
--exclude \".macromedia/Flash_Player\" \\\
--exclude \".adobe/Flash_Player\" \\\
--exclude \".ooo3/user/registry/cache\" \\\
--exclude \".tmw/updates\" \\\
--exclude \".wine/dosdevices\" \\\
--exclude \".fontconfig\" \\\
--exclude \".daimonin/srv_files\" \\\
--exclude \".boxee/UserData/Thumbnails\" \\\
--exclude \".dropbox-dist\" \\\
--exclude \".mozilla.bak\" \\\
--exclude \".winetrickscache\" \\\
--exclude \"Desktop\" \\\
--exclude \"Downloads\" \\\
--exclude \"Dropbox\" \\\
--exclude \"tmp\" \\\
--exclude \".mplab_ide\" \\\
--exclude \".PlayOnLinux\" \\\
--exclude \".thunderbird\" \\\
--exclude \".wine-browser\" \\\
--exclude \".nv\" \\\
--exclude \".vim/vimviews\" \\\
--exclude \".vim/vimswap\" \\\
--exclude \".mozilla.old\" \\\
--exclude \".local\" \\\
--exclude \"VirtualBox VMs\" \\\
--exclude \"Diablo III\" \\\
--exclude \"PlayOnLinux's virtual drives\" \\\
--exclude \"spiral\" \\\
--exclude \".config/freshwrapper-data\" \\\
--exclude \".config/libreoffice\" \\\
--exclude \".eclipse\" \\\
--exclude \".thumbnails\" ";




# Making VARs
$Backup_Date=`date +%F`;
chop($Backup_Date);
$Backup_Dir="$Tmp_Backup_Dir/backup/backup-$Backup_Date";
$Backup_username_dir="$Backup_Dir/$Backup_username";
$Dropbox_dir="/home/$Backup_username/Dropbox/configs/";
$RSYNC_COMMAND="rsync $RSYNC_PARAM $RSYNC_EXCLUDE";

#print "$Backup_Date\n$Backup_Dir\n$Backup_username_dir\n$Dropbox_dir\n$RSYNC_COMMAND";


# Make Dir
system("mkdir -p $Backup_Dir");
system("mkdir -p $Backup_Dir/configs");

# Sync /etc
print "Backing up /etc...\n";
system("nice -n 19 ionice -c2 -n7 rsync $RSYNC_PARAM /etc $Backup_Dir ");

# Sync /home
print "Backing up /home...\n";
system("nice -n 19 ionice -c2 -n7 rsync $RSYNC_PARAM $RSYNC_EXCLUDE $username_dir $Backup_Dir ");

# Sync /usr/script
print "Backing up /usr/script...\n";
system("nice -n 19 ionice -c2 -n7 rsync $RSYNC_PARAM /usr/scripts $Backup_Dir ");

# Copy config
print "Backing up configs...\n";
system("cp /usr/src/linux/.config $Backup_Dir/configs/");
# system("cp /var/lib/portage/world $Backup_Dir/configs/");

#Compress it
print "Compressing backup...\n";
system("cd $Tmp_Backup_Dir/backup;nice -n 19 ionice -c2 -n7 tar cvfJ backup-$Backup_Date.tar.xz backup-$Backup_Date ");

#Moving backup file to backup dir
print "Moving backup file to backup dir..\n";
$filesize = -s "$Tmp_Backup_Dir/backup/backup-$Backup_Date.tar.xz";
$filesize = sprintf "%.0f", $filesize/1024/1024;
system("nice -n 19 ionice -c2 -n7 mv $Tmp_Backup_Dir/backup/backup-$Backup_Date.tar.xz $Main_Backup_Dir");

#Cleaning up (not done)
#
print "Backup file $Main_Backup_Dir/backup-$Backup_Date.tar.xz\n";
print "File size: $filesize M\n";


print "Done.\n";
# copying etc and scripts
#cp -r /etc $Backup_Dir
#cp -r /usr/scripts $Backup_Dir

# linux kernel config
#mkdir $Backup_Dir/kernel
#cp /usr/src/linux/.config $Backup_Dir/kernel/config

# Home dir
#mkdir $Backup_username_dir
#cp -r /home/$Backup_username/.[0-9a-zA-Z]* $Backup_username_dir
#cp -r /home/$Backup_username/scriptsPersonal $Backup_username_dir



#cd $Main_Backup_Dir
#tar cfj $Backup_Dir.tar.bz2 $Backup_Dir
#rm -rf $Backup_Dir
#mv $Backup_Dir.tar.bz2 $Dropbox_dir

#cp /home/$Backup_username/magic_files_home $Backup_Dir
#cp /magic_files $Backup_Dir

# tar cvjf $Backup_Dest_Dir/backup-etc-$Backup_Date.tar.gz /etc &> /dev/null
# tar cvjf $Backup_Dest_Dir/backup-etc-$Backup_Date.tar.gz /etc &> /dev/null

# mkdir $Backup_Dir
# cd /
# tar cvfjp $Backup_Dir/backup-etc-$Backup_Date.tar.bz2 /etc
# tar cvfjp $Backup_Dir/backup-usr-scripts-$Backup_Date.tar.bz2 /usr/scripts
# cd $Backup_Home_Dir
# tar cvfjp $Backup_Dir/backup-home-dotfiles-$Backup_Date.tar.bz2 .[a-zA-Z0-9]* --exclude=.wine/drive_c --exclude=.ccache --exclude=.mozilla/firefox/*/*Cache --exclude=.opera/cache4 --exclude=.gqview/metadata --exclude=.gqview/thumbnails --exclude=.thumbnails --exclude=.daimonin/cache --exclude=.gimp-2.6/tmp --exclude=.local/share/Trash --exclude=.opera/images --exclude=.perltrash/ --exclude=.wesnoth --exclude=.winetrickscache --exclude=.VirtualBox/HardDisks --exclude=.VirtualBox/Machines/WinXP/Snapshots/ --exclude=.asc/asc2.cache --exclude=.macromedia/Flash_Player --exclude=.ooo3/user/registry/cache --exclude=.tmw/updates --exclude=.wine/dosdevices --exclude=.vegastrike* --exclude=.fontconfig --exclude=.daimonin/srv_files --exclude=.boxee/UserData/Thumbnails

