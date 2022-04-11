var primaryMember = db.isMaster().primary;

var me = db.isMaster().me;

if (me == primaryMember) {
  rs.stepDown();
}

db.adminCommand({ shutdown: 1, force: true });
