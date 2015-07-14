$DB = new SQL(Hostname => $HOSTNAME, Username => $USERNAME, Password => $PASSWORD, Database => $DATABASE);


package SQL;


use DBI;


sub new
{
    my $type = shift;
    my %params = @_;
    my $self = {};

    $self->{'Handle'} = undef;
    $self->{'Queries'} = 0;
    $self->{'Hostname'} = $params{'Hostname'};
    $self->{'Username'} = $params{'Username'};
    $self->{'Password'} = $params{'Password'};
    $self->{'Database'} = $params{'Database'};

    bless($self);

    return $self;
}



sub DESTROY
{
    my $self = shift;

    $self->Disconnect();
}



sub Connect
{
    my $self = shift;
    my $connect_string = "DBI:mysql:$self->{'Database'}:$self->{'Hostname'}";

    if( !$self->{'Handle'} )
    {
        $self->{'Handle'} = DBI->connect($connect_string, $self->{'Username'}, $self->{'Password'}, {'PrintError' => 0}) || Error(DBI->errstr(), 'MySQL Connection');
    }
}



sub Disconnect
{
    my $self = shift;

    if( $self->{'Handle'} )
    {
        $self->{'Handle'}->disconnect();
        $self->{'Handle'} = undef;
    }
}



sub Reconnect
{
    my $self = shift;

    $self->Disconnect();
    $self->Connect();
}



sub Count
{
    my $self = shift;
    my $query = shift;
    my $bind_values = shift || [];

    Error('No MySQL Database Connection', $query) if( !$self->{'Handle'} );

    my $result = $self->Query($query, $bind_values);
    my $count = $result->fetchrow();

    $self->Free($result);
  
    return $count;
}



sub Row
{
    my $self = shift;
    my $query = shift;
    my $bind_values = shift || [];

    Error('No MySQL Database Connection', $query) if( !$self->{'Handle'} );

    my $result = $self->Query($query, $bind_values);
    my $row = $self->NextRow($result);

    $self->Free($result);
  
    return $row;
}



sub Query
{
    my $self = shift;
    my $query = shift;
    my $bind_values = shift || [];
    my $sth = undef;

    Error('No MySQL Database Connection', $query) if( !$self->{'Handle'} );

    $sth = $self->{'Handle'}->prepare($query) || Error($self->{'Handle'}->errstr(), $query);
    $sth->execute(@$bind_values) || Error($self->{'Handle'}->errstr(), $query);

    $self->{'Queries'}++;

    return $sth;
}



sub NextRow
{
    my $self = shift;
    my $sth = shift;

    if( $sth )
    {
        return $sth->fetchrow_hashref();
    }

    return undef;
}



sub NextRowArray
{
    my $self = shift;
    my $sth = shift;

    if( $sth )
    {
        return $sth->fetchrow_arrayref;
    }

    return undef;
}



sub Columns
{
    my $self = shift;
    my $table = shift;
    my $columns = {};

    Error('No MySQL Database Connection', $query) if( !$self->{'Handle'} );

    my $result = $self->Query("DESCRIBE `$table`");
    while( $row = $self->NextRow($result) )
    {
        $columns->{$row->{'Field'}} = 1;
    }
    $self->Free($result);

    return $columns;
}



sub Free
{
    my $self = shift;
    my $sth = shift;

    if( $sth )
    {
        $sth->finish();
    }
}



sub InsertID
{
    my $self = shift;

    return $self->{'Handle'}->{'mysql_insertid'};
}



sub NumRows
{
    my $self = shift;
    my $sth = shift;

    if( $sth )
    {
        return $sth->rows();
    }

    return undef;
}



sub Insert
{
    my $self = shift;
    my $query = shift;
    my $bind_values = shift || [];
    my $rows = undef;

    Error('No MySQL Database Connection', $query) if( !$self->{'Handle'} );

    $rows = $self->{'Handle'}->do($query, undef, @$bind_values) || Error($self->{'Handle'}->errstr(), $query);

    $self->{'Queries'}++;

    return $rows;
}



sub BackupTables
{
    my $self = shift;
    my $tables = shift;
    my $backup_file = shift;
    my $replacements = shift;

    open(TABLES, ">$backup_file");
    flock(TABLES, 2);

    if( !ref($tables) )
    {
        $tables = [$tables];
    }

    for( @$tables )
    {
        my $table = $_;

        print TABLES "DELETE FROM $table;\n";

        my $result = $self->Query("SELECT * FROM $table");

        while( $row = $self->NextRowArray($result) )
        {
            $self->EscapeArray($row);

            $query = "INSERT INTO $table VALUES (" . join(',', @$row) . ");\n";

            for( keys %$replacements )
            {
                $query =~ s/$_/$replacements->{$_}/gi;
            }

            print TABLES $query;
        }

        $self->Free($result);
    }

    flock(TABLES, 8);
    close(TABLES);

    ::Mode(0666, $backup_file);
}



sub RestoreTables
{
    my $self = shift;
    my $backup_file = shift;
    my $replacements = shift;

    open(TABLES, "<$backup_file");
    flock(TABLES, 1);

    for( <TABLES> )
    {
        my $query = $_;

        ## Skip if empty line
        next if( ::IsEmptyString($query) );

        ## Remove trailing ; character
        $query =~ s/;$//;

        for( keys %$replacements )
        {
            $query =~ s/$_/$replacements->{$_}/gi;
        }

        $self->{'Handle'}->do($query) || LogError($self->{'Handle'}->errstr(), $query);
    }

    flock(TABLES, 8);
    close(TABLES);
}



sub EscapeArray
{
    my $self = shift;
    my $array = shift;

    for( @$array )
    {
        $_ = $self->{'Handle'}->quote($_);
    }
}



sub Update
{
    return shift->Insert(shift, shift);
}



sub Delete
{
    return shift->Insert(shift, shift);
}



sub LogError
{
    my $message = shift;
    my $query = shift;

    open(ERRLOG, ">>$::DDIR/error_log");
    flock(ERRLOG, 2);    
    print ERRLOG scalar(localtime()) . "\n\tError: $message\n\tQuery: $query\n\n";
    flock(ERRLOG, 8);
    close(ERRLOG);
}



sub Error
{
    my $message = shift;
    my $query   = shift;

    if( $::ERROR_LOG )
    {
        ::FileAppend("$::DDIR/error_log", scalar(localtime()) . "\n\tError: $message\n\tQuery: $query\n\n");
    }

    ::Header("Content-type: text/html\n\n");
    
    if( $ENV{'REQUEST_METHOD'} )
    {
        print <<"        HTML";
        <div align="center">
        <font face='Arial' size='2'>
        <h2>MySQL Error</h2>
        </font>

        <table width="500" cellspacing="2">
        <tr>
        <td valign="top">
        <font face='Arial' size='2'>
        <b>Error</b><br />
        </font>
        </td>
        <td>
        <font face='Arial' size='2'>
        <span id="Error">
        $message
        </span>
        <br />
        </font>
        </td>
        </tr>
        <tr>
        <td>
        <font face='Arial' size='2'>
        <b>Query</b><br />
        </font>
        </td>
        <td>
        <font face='Arial' size='2'>
        $query<br />
        </font>
        </td>
        </tr>
        </table>

        </div>
        HTML
    }
    else
    {
        print "\n\tError: $message\n";
        print "\tQuery: $query\n\n";
    }

    exit;
}