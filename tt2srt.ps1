#$dir = $args[0] -or "."
#$dir = ($args[0]) ? $args[0] : "."
$dir = "."
if($args[0]){$dir = "$($args[0])"}
echo "Folder: $dir"
$xml = Get-ChildItem $dir -Filter '*.xml' 
foreach( $file in $xml ) {
    $data = Get-Content $file.FullName -Encoding UTF8
    $is_tt = $false
    foreach($line in $data) {
        if(!$is_tt) {
            if($line -match '<tt xmlns:ttm="http://www.w3.org/ns/ttml') {
                $is_tt = $true
                echo "Found: $($file.Name)"
                $video = Get-ChildItem $dir -Include @("*.mp4","*.avi","*.mkv") -Recurse
                if(!$video) {
                    $srt = $file 
                }elseif($video -is [array]){
                    if($video.Length -eq 1 ) {
                        $srt = $video[0]
                    }else {
                        $srt = $file
                    }
                } else {
                    $srt = $video
                }
                $srt_name = $srt.FullName -replace $srt.Extension,".srt"
                echo "Convert to: $srt_name"
                $stream = [System.IO.StreamWriter] $srt_name
                
            }
        } elseif($line -match '<p\s+xml:id="subtitle(?<id>\d+)"\s+ttm:role="caption" begin="(?<start>\d{2}:\d{2}:[0-9,.]+)" end="(?<end>\d{2}:\d{2}:[0-9,.]+)">(?<text>[^<]*)</p>') {
            $stream.WriteLine( $Matches.id )
            $time = ( $Matches.start -replace "\.","," ) + " --> "  + ( $Matches.end -replace "\.","," ) 
            $stream.WriteLine( $time )
            $stream.WriteLine( $Matches.text )
            $stream.WriteLine( "" )
        }
    }
    if($is_tt) {
            $stream.Close();
    }
 }
 read-host "Press Enter"
