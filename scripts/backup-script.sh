# Backup Automation Script
# Creates timestamped backups of important directories

echo "========================================"
echo "     BACKUP AUTOMATION SCRIPT"
echo "========================================"
echo ""

# Configuration
BACKUP_SOURCE="$HOME/devops-practice"
BACKUP_DEST="$HOME/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_NAME="devops-practice-backup-$DATE"
BACKUP_PATH="$BACKUP_DEST/$BACKUP_NAME"

echo "📦 Backup Configuration:"
echo "  Source: $BACKUP_SOURCE"
echo "  Destination: $BACKUP_DEST"
echo "  Backup name: $BACKUP_NAME"
echo ""

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DEST" ]; then
    echo "📁 Creating backup directory..."
    mkdir -p "$BACKUP_DEST"
fi

# Check if source exists
if [ ! -d "$BACKUP_SOURCE" ]; then
    echo "❌ Error: Source directory not found!"
    exit 1
fi

# Calculate source size
SOURCE_SIZE=$(du -sh "$BACKUP_SOURCE" | awk '{print $1}')
echo "📊 Source size: $SOURCE_SIZE"
echo ""

# Create backup
echo "🔄 Creating backup..."
echo ""

# Copy with progress
cp -rv "$BACKUP_SOURCE" "$BACKUP_PATH"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Backup completed successfully!"
    echo ""
    
    # Show backup details
    BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | awk '{print $1}')
    echo "📊 Backup Statistics:"
    echo "  Location: $BACKUP_PATH"
    echo "  Size: $BACKUP_SIZE"
    echo "  Created: $(date)"
    echo ""
    
    # List recent backups
    echo "📂 Recent backups:"
    ls -lht "$BACKUP_DEST" | head -6
    echo ""
    
    # Count total backups
    BACKUP_COUNT=$(ls -1 "$BACKUP_DEST" | wc -l)
    echo "Total backups: $BACKUP_COUNT"
    
    # Check disk space
    echo ""
    echo "💾 Disk Space:"
    df -h "$BACKUP_DEST" | tail -1 | awk '{print "  Used: " $3 " / " $2 " (" $5 ")"}'
    
else
    echo "❌ Backup failed!"
    exit 1
fi

echo ""
echo "========================================"
echo "✅ Backup process complete!"
echo "========================================"
