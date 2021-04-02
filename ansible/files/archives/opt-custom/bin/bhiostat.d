#!/usr/sbin/dtrace -qs

 inline int INTERVAL 	= 3;

 /* 
  * Initialise variables
  */
 dtrace:::BEGIN 
 {
	prog = "bhyve";
	secs = INTERVAL;

	printf("PID\tDISK\t\tIOR\t\tIOW\t\tB_RD\t\tB_WR\n")
 }


 ::pread:entry,::preadv:entry
 /execname == prog/
 {
	self->file = fds[arg0].fi_name;
 }

 ::pread:return,::preadv:return
 /execname == prog && arg0 != -1/
 {
	@rbytes[pid, self->file] = sum(arg0);
	@ior[pid, self->file] = count();
 }

 ::pwrite:entry,::pwritev:entry
 /execname == prog/
 {
	/*
	printf("%d writing using to (%d) %s\n", pid, arg0, fds[arg0].fi_name);
	*/
	self->file = fds[arg0].fi_name;
 }

 ::pwrite:return,::pwritev:return
 /execname == prog && arg0 != -1/
 {
	@wbytes[pid, self->file] = sum(arg0);
	@iow[pid, self->file] = count();
 }


 /*
  * Timer
  */
 profile:::tick-1sec
 {
	secs--;
 }

 profile:::tick-1sec
 /secs == 0/
 {
	printa("%d\t%s\t\t%@d\t\t%@d\t\t%@d\t\t%@d\n", @ior, @iow, @rbytes, @wbytes);

	/* clear data */
	trunc(@ior);
	trunc(@iow);
	trunc(@rbytes);
	trunc(@wbytes);
	secs = INTERVAL;
 }

 dtrace:::END
 {
	/* clear data */
	trunc(@ior);
	trunc(@iow);
	trunc(@rbytes);
	trunc(@wbytes);
	secs = INTERVAL;
 }
