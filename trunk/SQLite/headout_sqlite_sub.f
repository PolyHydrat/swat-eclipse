      subroutine headout_sqlite_sub

!!     ~ ~ ~ PURPOSE ~ ~ ~
!!     this subroutine writes the headings to the major output files

!!    ~ ~ ~ INCOMING VARIABLES ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    hedb(:)     |NA            |column titles in subbasin output files
!!    hedr(:)     |NA            |column titles in reach output files
!!    hedrsv(:)   |NA            |column titles in reservoir output files
!!    heds(:)     |NA            |column titles in HRU output files
!!    hedwtr(:)   |NA            |column titles in HRU impoundment output
!!                               |file
!!    icolb(:)    |none          |space number for beginning of column in 
!!                               |subbasin output file
!!    icolr(:)    |none          |space number for beginning of column in
!!                               |reach output file
!!    icolrsv(:)  |none          |space number for beginning of column in
!!                               |reservoir output file
!!    icols(:)    |none          |space number for beginning of column in
!!                               |HRU output file
!!    ipdvab(:)   |none          |output variable codes for output.sub file
!!    ipdvar(:)   |none          |output variable codes for .rch file
!!    ipdvas(:)   |none          |output variable codes for output.hru file
!!    isproj      |none          |special project code:
!!                               |1 test rewind (run simulation twice)
!!    itotb       |none          |number of output variables printed (output.sub)
!!    itotr       |none          |number of output variables printed (.rch)
!!    itots       |none          |number of output variables printed (output.hru)
!!    msubo       |none          |maximum number of variables written to
!!                               |subbasin output file (output.sub)
!!    mhruo       |none          |maximum number of variables written to 
!!                               |HRU output file (output.hru)
!!    mrcho       |none          |maximum number of variables written to
!!                               |reach output file (.rch)
!!    prog        |NA            |program name and version
!!    title       |NA            |title lines from file.cio
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

!!    ~ ~ ~ LOCAL DEFINITIONS ~ ~ ~
!!    name        |units         |definition
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
!!    ilen        |none          |width of data columns in output file
!!    j           |none          |counter
!!    ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~


!!    ~ ~ ~ SUBROUTINES/FUNCTIONS CALLED ~ ~ ~
!!    header

!!    ~ ~ ~ ~ ~ ~ END SPECIFICATIONS ~ ~ ~ ~ ~ ~

      use parm

      integer :: j,colsubnum

      !table name
      tblsub = 'sub'

      !!delete any existing table
      call sqlite3_delete_table( db, tblsub)

      !!subbasin table
      !!The number of common columns
      tblsub_num = 0
      if (icalen == 0) then
        if(iprint == 2) then
            tblsub_num = 2
        else
            tblsub_num = 3
        end if
      else if (icalen == 1) then
        tblsub_num = 4
      end if

      !!get number of columns of sub
      colsubnum = 0
      if (ipdvab(1) > 0) then
        colsubnum = tblsub_num + itotb
      else
        colsubnum = tblsub_num + msubo
      end if

      !!create table sub
      allocate( colsub(colsubnum) )
      call sqlite3_column_props( colsub(1), "SUB", SQLITE_INT)
      if(icalen == 0) then
        call sqlite3_column_props( colsub(2), "YR", SQLITE_INT)
        if(iprint < 2) then
            call sqlite3_column_props( colsub(3), "MON", SQLITE_INT)
        end if
      else if(icalen == 1) then
        call sqlite3_column_props( colsub(2), "YR", SQLITE_INT)
        call sqlite3_column_props( colsub(3), "MO", SQLITE_INT)
        call sqlite3_column_props( colsub(4), "DA", SQLITE_INT)
      end if
      if (ipdvab(1) > 0) then
        do j = 1, itotb
         call sqlite3_column_props(colsub(tblsub_num+j),hedb(ipdvab(j)),
     &                                                      SQLITE_REAL)
        end do
      else
        do j = 1, msubo
            call sqlite3_column_props(colsub(tblsub_num+j), hedb(j),
     &                                                      SQLITE_REAL)
        end do
      end if
      call sqlite3_create_table( db, tblsub, colsub )

      !create index
      if(icalen == 0) then
        call sqlite3_create_index( db, "sub_index", tblsub,
     &                                                     "SUB,YR,MON")
      else if(icalen == 1) then
         call sqlite3_create_index( db, "sub_index", tblsub,
     &                                                   "SUB,YR,MO,DA")
      end if
      end
