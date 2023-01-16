     D**********************************************************************
     D* This code prevents this member from being /copy into the same
     D* program twice.   This allows you to /copy this file into your
     D* own /copy members, without worry about conflicting with programs
     D* that also /copy this.
     D**********************************************************************
     D/if defined(IFSIO_H)
     D/eof
     D/endif

     D/define IFSIO_H

     D*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
     D*:  DEFINITIONS EXPLAINED IN CHAPTER 2:
     D*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

     D**********************************************************************
     D*  Flags for use in open()
     D*
     D* More than one can be used -- add them together.
     D**********************************************************************
     D*                                            Reading Only
     D O_RDONLY        C                   1
     D*                                            Writing Only
     D O_WRONLY        C                   2
     D*                                            Reading & Writing
     D O_RDWR          C                   4
     D*                                            Create File if not exist
     D O_CREAT         C                   8
     D*                                            Exclusively create
     D O_EXCL          C                   16
     D*                                            Assign a CCSID
     D O_CCSID         C                   32
     D*                                            Truncate File to 0 bytes
     D O_TRUNC         C                   64
     D*                                            Append to File
     D O_APPEND        C                   256
     D*                                            Synchronous write
     D O_SYNC          C                   1024
     D*                                            Sync write, data only
     D O_DSYNC         C                   2048
     D*                                            Sync read
     D O_RSYNC         C                   4096
     D*                                            No controlling terminal
     D O_NOCTTY        C                   32768
     D*                                            Share with readers only
     D O_SHARE_RDONLY  C                   65536
     D*                                            Share with writers only
     D O_SHARE_WRONLY  C                   131072
     D*                                            Share with read & write
     D O_SHARE_RDWR    C                   262144
     D*                                            Share with nobody.
     D O_SHARE_NONE    C                   524288
     D*                                            Assign a code page
     D O_CODEPAGE      C                   8388608
     D*                                            Open in text-mode
     D O_TEXTDATA      C                   16777216
     D*                                            Allow text translation
     D*                                            on newly created file.
     D* Note: O_TEXT_CREAT requires all of the following flags to work:
     D*           O_CREAT+O_TEXTDATA+(O_CODEPAGE or O_CCSID)
     D O_TEXT_CREAT    C                   33554432
     D*                                            Inherit mode from dir
     D O_INHERITMODE   C                   134217728
     D*                                            Large file access
     D*                                            (for >2GB files)
     D O_LARGEFILE     C                   536870912


     D**********************************************************************
     D*      Mode Flags.
     D*         basically, the mode parm of open(), creat(), chmod(),etc
     D*         uses 9 least significant bits to determine the
     D*         file's mode. (peoples access rights to the file)
     D*
     D*           user:       owner    group    other
     D*           access:     R W X    R W X    R W X
     D*           bit:        8 7 6    5 4 3    2 1 0
     D*
     D* (This is accomplished by adding the flags below to get the mode)
     D**********************************************************************
     D*                                         owner authority
     D S_IRUSR         C                   256
     D S_IWUSR         C                   128
     D S_IXUSR         C                   64
     D S_IRWXU         C                   448
     D*                                         group authority
     D S_IRGRP         C                   32
     D S_IWGRP         C                   16
     D S_IXGRP         C                   8
     D S_IRWXG         C                   56
     D*                                         other people
     D S_IROTH         C                   4
     D S_IWOTH         C                   2
     D S_IXOTH         C                   1
     D S_IRWXO         C                   7


      *---------------------------------------------------------------------
      * open() -- Open File
      *
      * int open(const char *path, int oflag, . . .);
      *
      *     path = path name of file to open
      *    oflag = open flags
      *     mode = file mode, aka permissions.  (Reqd with O_CREAT flag)
      * codepage = code page to assign to file  (Reqd with O_CODEPAGE flag)
      *
      * Returns the file descriptor of the opened file
      *         or -1 if an error occurred
      *---------------------------------------------------------------------
     D open            PR            10I 0 extproc('open')
     D   path                          *   value options(*string)
     D   oflag                       10I 0 value
     D   mode                        10U 0 value options(*nopass)
     D   codepage                    10U 0 value options(*nopass)


      *---------------------------------------------------------------------
      * write() -- Write to stream file
      *
      * int write(int fildes, const void *buf, size_t nbyte);
      *
      *   fildes = file descriptor to write to
      *      buf = pointer to data to be written
      *    nbyte = number of bytes to write
      *
      * Returns the number of bytes written
      *         or a -1 if an error occurred
      *---------------------------------------------------------------------
     D write           PR            10I 0 extproc('write')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value


      *---------------------------------------------------------------------
      * read() -- Read from stream file
      *
      * int read(int fildes, void *buf, size_t nbyte);
      *
      *   fildes = file descriptor to read from
      *      buf = pointer to memory to read into
      *    nbyte = maximum number of bytes to read
      *
      * Returns the number of bytes read
      *         or a -1 if an error occurred
      *---------------------------------------------------------------------
     D read            PR            10I 0 extproc('read')
     D   fildes                      10I 0 value
     D   buf                           *   value
     D   nbyte                       10U 0 value


      *---------------------------------------------------------------------
      * close() -- Close file descriptor
      *
      * int close(int fildes);
      *
      *   fildes = file descriptor to close
      *
      * Returns 0 if successful
      *         or a -1 if an error occurred
      *---------------------------------------------------------------------
      /if not defined(CLOSE_PROTOTYPE)
     D close           PR            10I 0 extproc('close')
     D   fildes                      10I 0 value
      /define CLOSE_PROTOTYPE
      /endif

     D*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
     D*:  DEFINITIONS EXPLAINED IN CHAPTER 3:
     D*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

      **********************************************************************
      * Access mode flags for access()
      *
      *   F_OK = File Exists
      *   R_OK = Read Access
      *   W_OK = Write Access
      *   X_OK = Execute or Search
      **********************************************************************
     D F_OK            C                   0
     D R_OK            C                   4
     D W_OK            C                   2
     D X_OK            C                   1


      *--------------------------------------------------------------------
      * Determine file accessibility
      *
      * int access(const char *path, int amode)
      *
      *--------------------------------------------------------------------
     D access          PR            10I 0 ExtProc('access')
     D   Path                          *   Value Options(*string)
     D   amode                       10I 0 Value

      *--------------------------------------------------------------------
      * Change file permissions
      *
      * int chmod(const char *path, mode_t mode)
      *--------------------------------------------------------------------
     D chmod           PR            10I 0 ExtProc('chmod')
     D   path                          *   Value options(*string)
     D   mode                        10U 0 Value


      *--------------------------------------------------------------------
      * Rename a file or directory.
      *
      * int rename(const char *old, const char *new);
      *--------------------------------------------------------------------
     D rename          PR            10I 0 ExtProc('Qp0lRenameKeep')
     D   old                           *   Value options(*string)
     D   new                           *   Value options(*string)


      *--------------------------------------------------------------------
      * Remove Link to File.  (deletes 1 reference to a file.  If this
      *   is the last reference, the file itself is deleted.  See
      *   Chapter 3 for more info)
      *
      * int unlink(const char *path)
      *--------------------------------------------------------------------
     D unlink          PR            10I 0 ExtProc('unlink')
     D   path                          *   Value options(*string)


      **********************************************************************
      * File Information Structure (stat)
      *
      * struct stat {
      *  mode_t         st_mode;       /* File mode                       */
      *  ino_t          st_ino;        /* File serial number              */
      *  nlink_t        st_nlink;      /* Number of links                 */
      *  uid_t          st_uid;        /* User ID of the owner of file    */
      *  gid_t          st_gid;        /* Group ID of the group of file   */
      *  off_t          st_size;       /* For regular files, the file
      *                                 * size in bytes                   */
      *  time_t         st_atime;      /* Time of last access             */
      *  time_t         st_mtime;      /* Time of last data modification  */
      *  time_t         st_ctime;      /* Time of last file status change */
      *  dev_t          st_dev;        /* ID of device containing file    */
      *  size_t         st_blksize;    /* Size of a block of the file     */
      *  unsigned long  st_allocsize;  /* Allocation size of the file     */
      *  qp0l_objtype_t st_objtype;    /* AS/400 object type              */
      *  unsigned short st_codepage;   /* Object data codepage            */
      *  char           st_reserved1[66]; /* Reserved                     */
      * };
      *
      **********************************************************************
     D p_statds        S               *
     D statds          DS                  BASED(p_statds)
     D  st_mode                      10U 0
     D  st_ino                       10U 0
     D  st_nlink                      5U 0
     D  st_pad                        2A
     D  st_uid                       10U 0
     D  st_gid                       10U 0
     D  st_size                      10I 0
     D  st_atime                     10I 0
     D  st_mtime                     10I 0
     D  st_ctime                     10I 0
     D  st_dev                       10U 0
     D  st_blksize                   10U 0
     D  st_allocsize                 10U 0
     D  st_objtype                   12A
     D  st_codepage                   5U 0
     D  st_reserved1                 62A
     D  st_ino_gen_id                10U 0


      *--------------------------------------------------------------------
      * Get File Information
      *
      * int stat(const char *path, struct stat *buf)
      *--------------------------------------------------------------------
     D stat            PR            10I 0 ExtProc('stat')
     D   path                          *   value options(*string)
     D   buf                           *   value

     D*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
     D*:  DEFINITIONS EXPLAINED IN CHAPTER 4:
     D*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

     D**********************************************************************
     D* "whence" constants for use with lseek()
     D**********************************************************************
     D SEEK_SET        C                   CONST(0)
     D SEEK_CUR        C                   CONST(1)
     D SEEK_END        C                   CONST(2)

     D*--------------------------------------------------------------------
     D* Set File Read/Write Offset
     D*
     D* off_t lseek(int fildes, off_t offset, int whence)
     D*--------------------------------------------------------------------
     D lseek           PR            10I 0 ExtProc('lseek')
     D   fildes                      10I 0 value
     D   offset                      10I 0 value
     D   whence                      10I 0 value


      *--------------------------------------------------------------------
      * Get File Information from descriptor
      *
      * int fstat(int fildes, struct stat *buf)
      *--------------------------------------------------------------------
     D fstat           PR            10I 0 ExtProc('fstat')
     D   fildes                      10I 0 value
     D   buf                           *   value

     D*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
     D*:  DEFINITIONS EXPLAINED IN CHAPTER 7:
     D*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


     D**********************************************************************
     D*
     D* Directory Entry Structure (dirent)
     D*
     D* struct dirent {
     D*   char           d_reserved1[16];  /* Reserved                       */
     D*   unsigned int   d_reserved2;      /* Reserved                       */
     D*   ino_t          d_fileno;         /* The file number of the file    */
     D*   unsigned int   d_reclen;         /* Length of this directory entry
     D*                                     * in bytes                       */
     D*   int            d_reserved3;      /* Reserved                       */
     D*   char           d_reserved4[8];   /* Reserved                       */
     D*   qlg_nls_t      d_nlsinfo;        /* National Language Information
     D*                                     * about d_name                   */
     D*   unsigned int   d_namelen;        /* Length of the name, in bytes
     D*                                     * excluding NULL terminator      */
     D*   char           d_name[_QP0L_DIR_NAME]; /* Name...null terminated   */
     D*
     D* };
     D*
     D**********************************************************************
     D p_dirent        s               *
     D dirent          ds                  based(p_dirent)
     D   d_reserv1                   16A
     D   d_reserv2                   10U 0
     D   d_fileno                    10U 0
     D   d_reclen                    10U 0
     D   d_reserv3                   10I 0
     D   d_reserv4                    8A
     D   d_nlsinfo                   12A
     D     nls_ccsid                 10I 0 OVERLAY(d_nlsinfo:1)
     D     nls_cntry                  2A   OVERLAY(d_nlsinfo:5)
     D     nls_lang                   3A   OVERLAY(d_nlsinfo:7)
     D     nls_reserv                 3A   OVERLAY(d_nlsinfo:10)
     D   d_namelen                   10U 0
     D   d_name                     640A


     D*--------------------------------------------------------------------
     D* Make Directory
     D*
     D* int mkdir(const char *path, mode_t mode)
     D*--------------------------------------------------------------------
     D mkdir           PR            10I 0 ExtProc('mkdir')
     D   path                          *   Value options(*string)
     D   mode                        10U 0 Value


     D*--------------------------------------------------------------------
     D* Remove Directory
     D*
     D* int rmdir(const char *path)
     D*--------------------------------------------------------------------
     D rmdir           PR            10I 0 ExtProc('rmdir')
     D   path                          *   value options(*string)


     D*--------------------------------------------------------------------
     D* Change Directory
     D*
     D* int chdir(const char *path)
     D*--------------------------------------------------------------------
     D chdir           PR            10I 0 ExtProc('chdir')
     D   path                          *   Value Options(*string)


     D*--------------------------------------------------------------------
     D* Open a Directory
     D*
     D* DIR *opendir(const char *dirname)
     D*--------------------------------------------------------------------
     D opendir         PR              *   EXTPROC('opendir')
     D  dirname                        *   VALUE options(*string)


     D*--------------------------------------------------------------------
     D* Read Directory Entry
     D*
     D* struct dirent *readdir(DIR *dirp)
     D*--------------------------------------------------------------------
     D readdir         PR              *   EXTPROC('readdir')
     D  dirp                           *   VALUE


     D*--------------------------------------------------------------------
     D* Close a directory
     D*
     D* int closedir(DIR *dirp)
     D*--------------------------------------------------------------------
     D closedir        PR            10I 0 EXTPROC('closedir')
     D  dirhandle                      *   VALUE


     D*--------------------------------------------------------------------
     D* Get Current Working Directory
     D*
     D* char *getcwd(char *buf, int size);
     D*--------------------------------------------------------------------
     D getcwd          PR              *   EXTPROC('getcwd')
     D  buf                            *   VALUE
     D  size                         10I 0 VALUE
