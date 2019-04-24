#! /bin/sh
#
#  This is used to create a new environment and will be replaced 
#  when simp env is working
#
env_name=production
skeldir=/usr/share/simp/environments/simp
destdir_base=/etc/puppetlabs/code/environments
destdir="${destdir_base}/${env_name}"
env2dir=/var/simp/environments/${env_name}

if [[ ! -d $destdir ]]; then
  mkdir $destdir
fi

cd $skeldir
#create prime env
tar c data environment.conf manifests hiera.yaml | (cd $destdir; tar x)
chown -R root:puppet ${destdir}
chmod -R g+rX ${destdir}

if [[ ! -d $env2dir ]]; then
  mkdir -p $env2dir
fi
cd $skeldir
tar c simp_autofiles FakeCA site_files | (cd $env2dir; tar x)
#chown -R root:puppet $env2dir
chmod -R g+rX $env2dir

cd $destdir
simp puppetfile generate --skeleton > Puppetfile
simp puppetfile generate > Puppetfile.simp
chown root:puppet Puppetfile Puppetfile.simp
chmod 640 Puppetfile Puppetfile.simp
umask 0027
#FIXME hardcoded production instaed of using ${env_name}
sg puppet -c '/usr/share/simp/bin/r10k puppetfile install --puppetfile /etc/puppetlabs/code/environments/production/Puppetfile --moduledir /etc/puppetlabs/code/environments/production/modules'

# fix secondary environment in environment.conf


exit 0
