var currVersion = '3.6';
var verToUpgrade = '4.0';

print(
  `Checking if upgrade can be done from version: ${currVersion} to version: ${verToUpgrade}`
);

var dbVersion = db.version();

if (dbVersion.indexOf(currVersion)) {
  if (dbVersion.indexOf(verToUpgrade)) {
    print('Mongo seems to be upgraded, tarminating');
    quit(1);
  }

  print(
    `Version collision, installed version: ${dbVersion}, expected: ${currVersion}, terminating`
  );
  quit(1);
}

print(`Current version of db: ${dbVersion}`);

var checkBinary = db.serverBuildInfo().gitVersion;

if (checkBinary.indexOf('enterprise') != -1) {
  print('Current cluster uses enterprise binary');
} else {
  print('Current cluster uses community binary');
}

var { featureCompatibilityVersion } = db.adminCommand({
  getParameter: 1,
  featureCompatibilityVersion: 1,
});

if (!featureCompatibilityVersion.version == currVersion) {
  print(
    `featureCompatibilityVersion is not of version ${currVersion}, updating to ${currVersion}`
  );
  db.adminCommand({ setFeatureCompatibilityVersion: '3.6' });
}

var members = db.adminCommand({ replSetGetStatus: 1 }).members;

print(`Numbers of nodes to upgrade: ${members.length}`);

var primaryMember;

for (var member of members) {
  if (member.stateStr == 'PRIMARY') {
    primaryMember = member;
    print(`PRIMRAY member name: ${member.name}`);
  }
  if (member.stateStr == 'ROLLBACK' || member.stateStr == 'RECOVERING')
    throw new Error(`ReplicaSet is in invalid state: ${member.stateStr}`);
}

print('Checking active protocol for ReplicaSet');

var protocolVersion = rs.status().optimes.lastCommittedOpTime.t;
if (protocolVersion == -1) {
  print('Protocol in version pv0, upgrading to pv1');
  cfg = rs.conf();
  cfg.protocolVersion = 1;
  rs.reconfig(cfg);
}

print('Cluster is ready to be upgrade');
